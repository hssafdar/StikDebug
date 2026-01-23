//
//  LaunchHeartbeatIntent.swift
//  StikJIT
//
//  App Intent for launching the app and starting the heartbeat
//

import AppIntents
import Foundation

#if canImport(UIKit)
import UIKit
#endif

// Constants
private let heartbeatPollInterval: UInt64 = 1_000_000_000 // 1 second in nanoseconds
private let heartbeatMaxWaitTime: Int = 30 // Maximum wait time in seconds

@available(iOS 16.0, *)
struct LaunchAndStartHeartbeatIntent: AppIntent {
    static var title: LocalizedStringResource = "Launch StikDebug and Start Heartbeat"
    
    static var description = IntentDescription("Opens the StikDebug app, starts the heartbeat connection to the device, and returns you to your previous app once the connection is established.")
    
    // Open the app when this intent runs
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Check if pairing file exists
        let pairingFileURL = URL.documentsDirectory.appendingPathComponent("pairingFile.plist")
        guard FileManager.default.fileExists(atPath: pairingFileURL.path) else {
            return .result(dialog: "❌ No pairing file found. Please open StikDebug and pair with a device first.")
        }
        
        // Check if heartbeat is already active
        if isHeartbeatActive() {
            return .result(dialog: "✅ Heartbeat is already active and running.")
        }
        
        // Start the heartbeat on the main thread
        // The app will be opened by the system due to openAppWhenRun = true
        await MainActor.run {
            startHeartbeatInBackground(showErrorUI: false)
        }
        
        // Poll for heartbeat to become active with timeout
        var secondsWaited = 0
        while secondsWaited < heartbeatMaxWaitTime {
            try await Task.sleep(nanoseconds: heartbeatPollInterval)
            secondsWaited += 1
            
            if isHeartbeatActive() {
                // Heartbeat is now active! Provide haptic feedback
                await provideSuccessFeedback()
                
                // Try to minimize the app (return to previous app)
                await minimizeApp()
                
                return .result(dialog: "✅ Heartbeat started successfully! Returning to previous app.")
            }
        }
        
        // Timeout reached
        return .result(dialog: "⚠️ Heartbeat did not start within \(heartbeatMaxWaitTime) seconds. Please check StikDebug.")
    }
    
    // Helper to check if heartbeat is active
    private func isHeartbeatActive() -> Bool {
        guard globalHeartbeatToken > 0,
              let lastHeartbeat = lastHeartbeatDate,
              Date().timeIntervalSince(lastHeartbeat as Date) <= 15 else {
            return false
        }
        return true
    }
    
    // Provide haptic and notification feedback
    private func provideSuccessFeedback() async {
        await MainActor.run {
            #if canImport(UIKit)
            // Generate success haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        }
    }
    
    // Attempt to minimize the app to return to previous app
    private func minimizeApp() async {
        await MainActor.run {
            #if canImport(UIKit)
            // Try to minimize the app by opening a system URL
            // This is a workaround since iOS doesn't allow directly "going back"
            // Opening App-prefs: briefly can cause the app to minimize
            if let url = URL(string: "App-prefs:") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            #endif
        }
    }
}
