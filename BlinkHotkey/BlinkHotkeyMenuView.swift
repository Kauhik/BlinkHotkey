//
//  BlinkHotkeyMenuView.swift
//  BlinkHotkey
//
//  Created by Kaushik Manian on 28/3/25.
//

import SwiftUI
import SwiftData

struct BlinkHotkeyMenuView: View {
    @EnvironmentObject var blinkDetector: BlinkDetector
    @Environment(\.modelContext) private var modelContext
    
    // Query the first settings record (if any)
    @Query private var settings: [BlinkHotkeySettings]

    var body: some View {
        VStack(alignment: .leading) {
            if let setting = settings.first {
                Toggle("Enable Blink Detection", isOn: $blinkDetector.isDetectionEnabled)
                    .onChange(of: blinkDetector.isDetectionEnabled) { newValue in
                        // Update SwiftData directly, no perform(...) needed
                        setting.isDetectionEnabled = newValue
                        do {
                            try modelContext.save()
                        } catch {
                            print("Error saving detectionEnabled: \(error)")
                        }

                        // Start/stop camera detection
                        if newValue {
                            blinkDetector.startDetection()
                        } else {
                            blinkDetector.stopDetection()
                        }
                    }

                Button("Calibrate Blinks") {
                    blinkDetector.calibrate()
                    // Store calibration state in SwiftData
                    setting.isCalibrated = blinkDetector.isCalibrated
                    do {
                        try modelContext.save()
                    } catch {
                        print("Error saving calibration state: \(error)")
                    }
                }

                Button("Map Double Blink → \(setting.doubleBlinkHotkey)") {
                    // Pass the ModelContext so BlinkDetector can save
                    blinkDetector.mapDoubleBlinkToHotkey(setting, context: modelContext)
                }

                Divider()

                Button("Quit") {
                    NSApp.terminate(nil)
                }
            } else {
                // If no settings record, show a button to create it
                Button("Initialize BlinkHotkey Settings") {
                    createNewSettings()
                }
            }
        }
        .padding()
        .frame(width: 220)
    }

    private func createNewSettings() {
        let newSettings = BlinkHotkeySettings()
        modelContext.insert(newSettings)
        do {
            try modelContext.save()
        } catch {
            print("Error creating new BlinkHotkeySettings: \(error)")
        }
    }
}
