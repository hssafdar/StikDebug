//
//  KillProcessIntents.swift
//  StikJIT
//
//  App Intents for killing commonly useful processes via iOS Shortcuts
//

import AppIntents
import Foundation

// MARK: - Kill CommCenter Intent
@available(iOS 16.0, *)
struct KillCommCenterIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill CommCenter Process"
    
    static var description = IntentDescription("Kills the CommCenter process on the connected device, which manages cellular and phone services. Useful for fixing carrier issues. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return try await killProcess(
            processName: "CommCenter",
            successMessage: "✅ Successfully killed CommCenter. Cellular services should restart momentarily.",
            processDescription: "CommCenter"
        )
    }
}

// MARK: - Kill MediaServerd Intent
@available(iOS 16.0, *)
struct KillMediaServerdIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill MediaServerd Process"
    
    static var description = IntentDescription("Kills the mediaserverd process on the connected device, which manages audio and media services. Useful for fixing audio glitches. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return try await killProcess(
            processName: "mediaserverd",
            successMessage: "✅ Successfully killed mediaserverd. Audio services should restart momentarily.",
            processDescription: "mediaserverd"
        )
    }
}

// MARK: - Kill MediaPlaybackd Intent
@available(iOS 16.0, *)
struct KillMediaPlaybackdIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill MediaPlaybackd Process"
    
    static var description = IntentDescription("Kills the mediaplaybackd process on the connected device, which manages media playback. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return try await killProcess(
            processName: "mediaplaybackd",
            successMessage: "✅ Successfully killed mediaplaybackd. Media playback services should restart momentarily.",
            processDescription: "mediaplaybackd"
        )
    }
}

// MARK: - Kill Bluetoothd Intent
@available(iOS 16.0, *)
struct KillBluetoothdIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill Bluetoothd Process"
    
    static var description = IntentDescription("Kills the bluetoothd process on the connected device, which manages Bluetooth connections. Useful for fixing Bluetooth connection issues. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return try await killProcess(
            processName: "bluetoothd",
            successMessage: "✅ Successfully killed bluetoothd. Bluetooth services should restart momentarily.",
            processDescription: "bluetoothd"
        )
    }
}

// MARK: - Kill Wifid Intent
@available(iOS 16.0, *)
struct KillWifidIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill Wifid Process"
    
    static var description = IntentDescription("Kills the wifid process on the connected device, which manages WiFi connections. Useful for fixing WiFi issues. Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return try await killProcess(
            processName: "wifid",
            successMessage: "✅ Successfully killed wifid. WiFi services should restart momentarily.",
            processDescription: "wifid"
        )
    }
}

// MARK: - Kill SpringBoard Intent
@available(iOS 16.0, *)
struct KillSpringBoardIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill SpringBoard Process"
    
    static var description = IntentDescription("Kills the SpringBoard process on the connected device, which restarts the home screen (soft respring). Requires an active heartbeat connection.")
    
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return try await killProcess(
            processName: "SpringBoard",
            successMessage: "✅ Successfully killed SpringBoard. The device will perform a soft respring.",
            processDescription: "SpringBoard"
        )
    }
}

// MARK: - Helper Function
@available(iOS 16.0, *)
private func killProcess(processName: String, successMessage: String, processDescription: String) async throws -> some IntentResult & ProvidesDialog {
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
    for item in processList {
        guard let processDict = item as? NSDictionary,
              let pidNumber = processDict["pid"] as? NSNumber,
              let path = processDict["path"] as? String else {
            continue
        }
        
        // Clean the path by removing file:// prefix if present
        let cleanPath = path.replacingOccurrences(of: "file://", with: "")
        
        // Check if this is our target process using suffix or exact match for precision
        // This prevents false positives (e.g., searching 'media' shouldn't match both 'mediaserverd' and 'mediaplaybackd')
        let lowerCleanPath = cleanPath.lowercased()
        let lowerProcessName = processName.lowercased()
        if lowerCleanPath.hasSuffix("/\(lowerProcessName)") || lowerCleanPath == lowerProcessName {
            targetPID = Int32(pidNumber.intValue)
            break
        }
    }
    
    guard let pid = targetPID else {
        return .result(dialog: "❌ Could not find \(processDescription) process. The process may not be running or may have a different name.")
    }
    
    // Kill the process
    var killError: NSError?
    let success = KillDeviceProcess(pid, &killError)
    
    if success {
        return .result(dialog: successMessage + " (PID \(pid))")
    } else {
        let errorMessage = killError?.localizedDescription ?? "Unknown error"
        return .result(dialog: "❌ Failed to kill \(processDescription) (PID \(pid)): \(errorMessage)")
    }
}
