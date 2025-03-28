//
//  BlinkHotkeySettings.swift
//  BlinkHotkey
//
//  Created by Kaushik Manian on 28/3/25.
//

import Foundation
import SwiftData

@Model
final class BlinkHotkeySettings {
    @Attribute(.unique) var id: UUID
    var isDetectionEnabled: Bool
    var isCalibrated: Bool
    var doubleBlinkHotkey: String
    var calibrationNotes: String  // store threshold data or other calibration info

    init(
        id: UUID = UUID(),
        isDetectionEnabled: Bool = false,
        isCalibrated: Bool = false,
        doubleBlinkHotkey: String = "⌘N",
        calibrationNotes: String = ""
    ) {
        self.id = id
        self.isDetectionEnabled = isDetectionEnabled
        self.isCalibrated = isCalibrated
        self.doubleBlinkHotkey = doubleBlinkHotkey
        self.calibrationNotes = calibrationNotes
    }
}
