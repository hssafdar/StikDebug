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
        let processesToKill = ["mediaserverd", "mediaplaybackd"]
        
        for processName in processesToKill {
            if let pid = findProcessByName(processName, in: processList) {
                var killError: NSError?
                let success = KillDeviceProcess(pid, &killError)
                
                if success {
                    results.append("✅ Killed \(processName) (PID \(pid))")
                } else {
                    let errorMessage = killError?.localizedDescription ?? "Unknown error"
                    results.append("❌ Failed to kill \(processName) (PID \(pid)): \(errorMessage)")
                }
            } else {
                results.append("⚠️ \(processName) not found (may not be running)")
            }
        }
        
        let resultMessage = results.joined(separator: "\n")
        return .result(dialog: "Media services fix completed:\n\n\(resultMessage)")
    }
}
