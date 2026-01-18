//
//  StikDebugShortcuts.swift
//  StikJIT
//
//  AppShortcutsProvider for exposing intents to the Shortcuts app
//

import Foundation
import AppIntents

/// Provides shortcuts for StikDebug app
@available(iOS 16.0, *)
struct StikDebugShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: KillBackboarddIntent(),
            phrases: [
                "Kill backboardd with \(.applicationName)",
                "Restart SpringBoard with \(.applicationName)",
                "Respring with \(.applicationName)"
            ],
            shortTitle: "Kill Backboardd",
            systemImageName: "arrow.clockwise.circle.fill"
        )
    }
}
