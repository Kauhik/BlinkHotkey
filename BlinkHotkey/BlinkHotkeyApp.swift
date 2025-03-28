//
//  BlinkHotkeyApp.swift
//  BlinkHotkey
//
//  Created by Kaushik Manian on 28/3/25.
//

import SwiftUI
import SwiftData

@main
struct BlinkHotkeyApp: App {
    // Create a shared container for both Item & BlinkHotkeySettings
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            BlinkHotkeySettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // The detector for camera logic
    @StateObject private var blinkDetector = BlinkDetector()

    var body: some Scene {
        // Main window
        WindowGroup {
            ContentView()
                .environmentObject(blinkDetector)
                .modelContainer(sharedModelContainer)
        }
        .modelContainer(sharedModelContainer)

        // Menu bar extra (macOS 13+)
        MenuBarExtra("BlinkHotkey", systemImage: "eye") {
            BlinkHotkeyMenuView()
                .environmentObject(blinkDetector)
                .modelContainer(sharedModelContainer)
        }
        // Optional: .menuBarExtraStyle(.window) to show a larger popover
    }
}
