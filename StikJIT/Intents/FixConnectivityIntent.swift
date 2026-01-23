//
//  FixConnectivityIntent.swift
//  StikJIT
//
//  Combined intent for killing connectivity-related processes
//

import AppIntents
import Foundation

// MARK: - Fix Connectivity Intent
@available(iOS 16.0, *)
struct FixConnectivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Fix Connectivity Services"
    
    static var description = IntentDescription("Kills CommCenter, wifid, and bluetoothd processes on the connected device to fix cellular, WiFi, and Bluetooth issues. Requires an active heartbeat connection.")
    
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
        
        // Try to kill all connectivity processes
        var results: [String] = []
        let processesToKill = [
            ("CommCenter", "CommCenter"),
            ("wifid", "wifid"),
            ("bluetoothd", "bluetoothd")
        ]
        
        for (processName, displayName) in processesToKill {
            if let pid = findProcessByName(processName, in: processList) {
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
        return .result(dialog: "Connectivity services fix completed:\n\n\(resultMessage)")
    }
}
