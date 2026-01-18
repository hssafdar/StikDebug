//
//  LaunchHeartbeatIntent.swift
//  StikJIT
//
//  App Intent for launching the app and starting the heartbeat
//

import AppIntents
import Foundation

// Constants
private let heartbeatStartupDelay: UInt64 = 2_000_000_000 // 2 seconds in nanoseconds

@available(iOS 16.0, *)
struct LaunchAndStartHeartbeatIntent: AppIntent {
    static var title: LocalizedStringResource = "Launch StikDebug and Start Heartbeat"
    
    static var description = IntentDescription("Opens the StikDebug app and starts the heartbeat connection to the device.")
    
    // Open the app when this intent runs
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Check if pairing file exists
        let pairingFileURL = URL.documentsDirectory.appendingPathComponent("pairingFile.plist")
        guard FileManager.default.fileExists(atPath: pairingFileURL.path) else {
            return .result(dialog: "❌ No pairing file found. Please open StikDebug and pair with a device first.")
        }
        
        // Check if heartbeat is already active
        if globalHeartbeatToken > 0,
           let lastHeartbeat = lastHeartbeatDate,
           Date().timeIntervalSince(lastHeartbeat as Date) <= 15 {
            return .result(dialog: "✅ Heartbeat is already active and running.")
        }
        
        // Start the heartbeat on the main thread
        // The app will be opened by the system due to openAppWhenRun = true
        // We need to trigger the heartbeat start
        await MainActor.run {
            startHeartbeatInBackground(showErrorUI: false)
        }
        
        // Wait a bit for the heartbeat to start
        try await Task.sleep(nanoseconds: heartbeatStartupDelay)
        
        // Check if heartbeat started successfully
        if globalHeartbeatToken > 0,
           let lastHeartbeat = lastHeartbeatDate,
           Date().timeIntervalSince(lastHeartbeat as Date) <= 15 {
            return .result(dialog: "✅ StikDebug opened and heartbeat started successfully.")
        } else {
            return .result(dialog: "⚠️ StikDebug opened, but heartbeat may not have started. Please check the app.")
        }
    }
}
