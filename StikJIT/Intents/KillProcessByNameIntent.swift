//
//  KillProcessByNameIntent.swift
//  StikJIT
//
//  App Intent for killing any process by name via iOS Shortcuts
//

import AppIntents
import Foundation

@available(iOS 16.0, *)
struct KillProcessByNameIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill Process By Name"
    
    static var description = IntentDescription("Kills a process by its name on the connected device. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    // Parameter for the process name
    @Parameter(title: "Process Name", description: "The name of the process to kill (e.g., 'mediaserverd', 'SpringBoard')")
    var processName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Kill \(\.$processName) with StikDebug")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Validate input
        guard !processName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .result(dialog: "❌ Please provide a process name.")
        }
        
        let trimmedProcessName = processName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if heartbeat is active
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
        
        // Find the target process
        var targetPID: Int32?
        var foundPath: String?
        for item in processList {
            guard let processDict = item as? NSDictionary,
                  let pidNumber = processDict["pid"] as? NSNumber,
                  let path = processDict["path"] as? String else {
                continue
            }
            
            // Clean the path by removing file:// prefix if present
            let cleanPath = path.replacingOccurrences(of: "file://", with: "")
            
            // Check if this is our target process (case-insensitive, partial match)
            if cleanPath.lowercased().contains(trimmedProcessName.lowercased()) {
                targetPID = Int32(pidNumber.intValue)
                foundPath = cleanPath
                break
            }
        }
        
        guard let pid = targetPID else {
            return .result(dialog: "❌ Could not find '\(trimmedProcessName)' process. The process may not be running or may have a different name.")
        }
        
        // Kill the process
        var killError: NSError?
        let success = KillDeviceProcess(pid, &killError)
        
        if success {
            // Extract just the process name from the path for the message
            let displayName = (foundPath as NSString?)?.lastPathComponent ?? trimmedProcessName
            return .result(dialog: "✅ Successfully killed \(displayName) (PID \(pid)).")
        } else {
            let errorMessage = killError?.localizedDescription ?? "Unknown error"
            return .result(dialog: "❌ Failed to kill '\(trimmedProcessName)' (PID \(pid)): \(errorMessage)")
        }
    }
}
