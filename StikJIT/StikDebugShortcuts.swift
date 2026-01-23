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
        [
            // Launch & Start Heartbeat
            AppShortcut(
                intent: LaunchAndStartHeartbeatIntent(),
                phrases: [
                    "Start \(.applicationName) heartbeat",
                    "Launch \(.applicationName) and start heartbeat",
                    "Start heartbeat with \(.applicationName)",
                    "Open \(.applicationName) and start heartbeat"
                ],
                shortTitle: "Start Heartbeat",
                systemImageName: "heart.fill"
            ),
            
            // Fix Media Services (Combined)
            AppShortcut(
                intent: FixMediaIntent(),
                phrases: [
                    "Fix media with \(.applicationName)",
                    "Fix audio with \(.applicationName)",
                    "Restart media services with \(.applicationName)",
                    "Fix audio and media with \(.applicationName)"
                ],
                shortTitle: "Fix Media",
                systemImageName: "speaker.wave.3.fill"
            ),
            
            // Fix Connectivity Services (Combined)
            AppShortcut(
                intent: FixConnectivityIntent(),
                phrases: [
                    "Fix connectivity with \(.applicationName)",
                    "Fix network with \(.applicationName)",
                    "Restart network services with \(.applicationName)",
                    "Fix WiFi and Bluetooth with \(.applicationName)"
                ],
                shortTitle: "Fix Connectivity",
                systemImageName: "network"
            ),
            
            // Kill Backboardd
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
            ),
            
            // Kill CommCenter
            AppShortcut(
                intent: KillCommCenterIntent(),
                phrases: [
                    "Kill CommCenter with \(.applicationName)",
                    "Fix cellular with \(.applicationName)",
                    "Restart cellular with \(.applicationName)",
                    "Fix carrier issues with \(.applicationName)"
                ],
                shortTitle: "Kill CommCenter",
                systemImageName: "antenna.radiowaves.left.and.right"
            ),
            
            // Kill MediaServerd
            AppShortcut(
                intent: KillMediaServerdIntent(),
                phrases: [
                    "Kill mediaserverd with \(.applicationName)",
                    "Restart audio with \(.applicationName)",
                    "Fix audio glitches with \(.applicationName)"
                ],
                shortTitle: "Kill MediaServerd",
                systemImageName: "speaker.wave.3"
            ),
            
            // Kill MediaPlaybackd
            AppShortcut(
                intent: KillMediaPlaybackdIntent(),
                phrases: [
                    "Kill mediaplaybackd with \(.applicationName)",
                    "Restart media playback with \(.applicationName)",
                    "Fix media playback with \(.applicationName)"
                ],
                shortTitle: "Kill MediaPlaybackd",
                systemImageName: "play.circle"
            ),
            
            // Kill Bluetoothd
            AppShortcut(
                intent: KillBluetoothdIntent(),
                phrases: [
                    "Kill bluetoothd with \(.applicationName)",
                    "Fix Bluetooth with \(.applicationName)",
                    "Restart Bluetooth with \(.applicationName)",
                    "Fix Bluetooth connection with \(.applicationName)"
                ],
                shortTitle: "Kill Bluetoothd",
                systemImageName: "bluetooth"
            ),
            
            // Kill Wifid
            AppShortcut(
                intent: KillWifidIntent(),
                phrases: [
                    "Kill wifid with \(.applicationName)",
                    "Fix WiFi with \(.applicationName)",
                    "Restart WiFi with \(.applicationName)",
                    "Fix WiFi connection with \(.applicationName)"
                ],
                shortTitle: "Kill Wifid",
                systemImageName: "wifi"
            ),
            
            // Kill SpringBoard
            AppShortcut(
                intent: KillSpringBoardIntent(),
                phrases: [
                    "Kill SpringBoard with \(.applicationName)",
                    "Respring with \(.applicationName)",
                    "Restart home screen with \(.applicationName)",
                    "Soft respring with \(.applicationName)"
                ],
                shortTitle: "Kill SpringBoard",
                systemImageName: "house.circle"
            ),
            
            // Generic Kill Process By Name
            AppShortcut(
                intent: KillProcessByNameIntent(),
                phrases: [
                    "Kill process with \(.applicationName)",
                    "Kill \(\.$processName) with \(.applicationName)"
                ],
                shortTitle: "Kill Process",
                systemImageName: "xmark.circle"
            )
        ]
    }
}
