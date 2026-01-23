//
//  FixMediaIntent.swift
//  StikJIT
//
//  Combined intent for killing media-related processes
//

import AppIntents
import Foundation

// MARK: - Fix Media Intent
@available(iOS 16.0, *)
struct FixMediaIntent: AppIntent {
    static var title: LocalizedStringResource = "Fix Media Services"
    
    static var description = IntentDescription("Kills both mediaserverd and mediaplaybackd processes on the connected device to fix audio and media playback issues. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
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
        
        // Try to kill both media processes
        var results: [String] = []
        let processesToKill = [
            ("mediaserverd", "mediaserverd"),
            ("mediaplaybackd", "mediaplaybackd")
        ]
        
        for (processName, displayName) in processesToKill {
            if let pid = findProcess(named: processName, in: processList) {
                var killError: NSError?
                let success = KillDeviceProcess(pid, &killError)
                
                if success {
                    results.append("✅ Killed \(displayName) (PID \(pid))")
                } else {
                    let errorMessage = killError?.localizedDescription ?? "Unknown error"
                    results.append("❌ Failed to kill \(displayName) (PID \(pid)): \(errorMessage)")
                }
            } else {
                results.append("⚠️ \(displayName) not found (may not be running)")
            }
        }
        
        let resultMessage = results.joined(separator: "\n")
        return .result(dialog: "Media services fix completed:\n\n\(resultMessage)")
    }
    
    // Helper function to find a process by name
    private func findProcess(named processName: String, in processList: NSArray) -> Int32? {
        for item in processList {
            guard let processDict = item as? NSDictionary,
                  let pidNumber = processDict["pid"] as? NSNumber,
                  let path = processDict["path"] as? String else {
                continue
            }
            
            // Clean the path by removing file:// prefix if present
            let cleanPath = path.replacingOccurrences(of: "file://", with: "")
            
            // Check if this is our target process using suffix or exact match
            let lowerCleanPath = cleanPath.lowercased()
            let lowerProcessName = processName.lowercased()
            if lowerCleanPath.hasSuffix("/\(lowerProcessName)") || lowerCleanPath == lowerProcessName {
                return Int32(pidNumber.intValue)
            }
        }
        return nil
    }
}
