//
//  KillBackboarddIntent.swift
//  StikJIT
//
//  iOS Shortcuts support for killing backboardd process
//

import Foundation
import AppIntents

/// Error types for KillBackboarddIntent
enum KillBackboarddError: Error, LocalizedError {
    case heartbeatNotActive
    case failedToFetchProcesses(String)
    case processNotFound
    case killOperationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .heartbeatNotActive:
            return "Heartbeat connection is not active. Please ensure your device is connected and the heartbeat is running."
        case .failedToFetchProcesses(let message):
            return "Failed to fetch process list: \(message)"
        case .processNotFound:
            return "The backboardd process was not found on the device."
        case .killOperationFailed(let message):
            return "Failed to kill backboardd process: \(message)"
        }
    }
}

/// App Intent to kill the backboardd process, causing a soft SpringBoard restart
@available(iOS 16.0, *)
struct KillBackboarddIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill Backboardd"
    static var description = IntentDescription("Kills the backboardd process on the connected iOS device, causing a soft SpringBoard restart without a full device reboot.")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Check if heartbeat is active
        guard pubHeartBeat else {
            throw KillBackboarddError.heartbeatNotActive
        }
        
        // Fetch the process list
        var error: NSError?
        guard let processList = FetchDeviceProcessList(&error) else {
            let errorMessage = error?.localizedDescription ?? "Unknown error"
            throw KillBackboarddError.failedToFetchProcesses(errorMessage)
        }
        
        // Find backboardd process
        var backboarddPID: Int32?
        for item in processList {
            guard let processDict = item as? NSDictionary else { continue }
            
            // Check if this is backboardd by name or path
            if let name = processDict["name"] as? String,
               name == "backboardd" {
                if let pidNumber = processDict["pid"] as? NSNumber {
                    backboarddPID = Int32(pidNumber.intValue)
                    break
                }
            }
            
            if let executablePath = processDict["path"] as? String,
               executablePath.contains("backboardd") {
                if let pidNumber = processDict["pid"] as? NSNumber {
                    backboarddPID = Int32(pidNumber.intValue)
                    break
                }
            }
        }
        
        guard let pid = backboarddPID else {
            throw KillBackboarddError.processNotFound
        }
        
        // Kill the process
        var killError: NSError?
        let success = KillDeviceProcess(pid, &killError)
        
        if !success {
            let errorMessage = killError?.localizedDescription ?? "Unknown error"
            throw KillBackboarddError.killOperationFailed(errorMessage)
        }
        
        return .result(
            dialog: IntentDialog("Successfully killed backboardd (PID: \(pid)). SpringBoard should restart momentarily.")
        )
    }
}
