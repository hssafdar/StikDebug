//
//  StikDebugShortcuts.swift
//  StikJIT
//
//  App Shortcuts provider for StikDebug intents
//

import AppIntents

@available(iOS 16.0, *)
struct StikDebugShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: KillBackboarddIntent(),
            phrases: [
                "Kill backboardd with \(.applicationName)",
                "Restart SpringBoard with \(.applicationName)",
                "Kill backboardd using \(.applicationName)",
                "Restart device SpringBoard with \(.applicationName)"
            ],
            shortTitle: "Kill Backboardd",
            systemImageName: "arrow.clockwise.circle"
        )
    }
}
