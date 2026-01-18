//
//  KillBackboarddIntent.swift
//  StikJIT
//
//  App Intent for killing the backboardd process via iOS Shortcuts
//

import AppIntents
import Foundation

@available(iOS 16.0, *)
struct KillBackboarddIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill Backboardd Process"
    
    static var description = IntentDescription("Kills the backboardd process on the connected device, which restarts SpringBoard. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Check if heartbeat is active by checking lastHeartbeatDate and globalHeartbeatToken
        // globalHeartbeatToken > 0 means a heartbeat has been started
        // lastHeartbeatDate within 15 seconds means it's still active
        guard globalHeartbeatToken > 0,
              let lastHeartbeat = lastHeartbeatDate,
              Date().timeIntervalSince(lastHeartbeat as Date) <= 15 else {
            return .result(dialog: "❌ Heartbeat connection is not active. Please ensure the device is connected and the heartbeat is running in StikDebug.")
        }
        
        // Fetch the process list
        var fetchError: NSError?
        guard let processList = FetchDeviceProcessList(&fetchError) else {
            let errorMessage = fetchError?.localizedDescription ?? "Unknown error"
            return .result(dialog: "❌ Failed to fetch process list: \(errorMessage)")
        }
        
        // Find backboardd process
        var backboarddPID: Int32?
        for item in processList {
            guard let processDict = item as? NSDictionary,
                  let pidNumber = processDict["pid"] as? NSNumber,
                  let path = processDict["path"] as? String else {
                continue
            }
            
            // Clean the path by removing file:// prefix if present
            let cleanPath = path.replacingOccurrences(of: "file://", with: "")
            
            // Check if this is backboardd by checking if the path ends with /backboardd
            // This is more specific than just checking if it contains the string
            if cleanPath.hasSuffix("/backboardd") || cleanPath == "backboardd" {
                backboarddPID = Int32(pidNumber.intValue)
                break
            }
        }
        
        guard let pid = backboarddPID else {
            return .result(dialog: "❌ Could not find backboardd process. The process may not be running or may have a different name.")
        }
        
        // Kill the process
        var killError: NSError?
        let success = KillDeviceProcess(pid, &killError)
        
        if success {
            return .result(dialog: "✅ Successfully killed backboardd (PID \(pid)). SpringBoard should restart momentarily.")
        } else {
            let errorMessage = killError?.localizedDescription ?? "Unknown error"
            return .result(dialog: "❌ Failed to kill backboardd (PID \(pid)): \(errorMessage)")
        }
    }
}
