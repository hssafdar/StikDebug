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
        
        // Helper function to extract PID from process dictionary
        func extractPID(from dict: NSDictionary) -> Int32? {
            guard let pidNumber = dict["pid"] as? NSNumber else { return nil }
            return Int32(pidNumber.intValue)
        }
        
        // Find backboardd process
        var backboarddPID: Int32?
        for item in processList {
            guard let processDict = item as? NSDictionary else { continue }
            
            // Check if this is backboardd by name
            if let name = processDict["name"] as? String, name == "backboardd" {
                backboarddPID = extractPID(from: processDict)
                break
            }
            
            // Check if this is backboardd by path (more precise matching)
            if let executablePath = processDict["path"] as? String {
                let cleanedPath = executablePath.replacingOccurrences(of: "file://", with: "")
                if cleanedPath.hasSuffix("/backboardd") || cleanedPath == "backboardd" {
                    backboarddPID = extractPID(from: processDict)
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
