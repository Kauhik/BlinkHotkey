//
//  BlinkDetector.swift
//  BlinkHotkey
//
//  Created by Kaushik Manian on 28/3/25.
//

import SwiftUI
import Combine
import AVFoundation
import Vision
import AppKit // For NSAlert, etc.
import SwiftData

/// Must inherit from NSObject for AVCaptureVideoDataOutputSampleBufferDelegate conformance
class BlinkDetector: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isDetectionEnabled = false
    @Published var isCalibrated = false

    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?

    override init() {
        super.init()
    }

    // Start the camera feed
    func startDetection() {
        guard !isDetectionEnabled else { return }
        isDetectionEnabled = true
        setupCaptureSession()
        captureSession?.startRunning()
    }

    // Stop detection
    func stopDetection() {
        guard isDetectionEnabled else { return }
        isDetectionEnabled = false
        captureSession?.stopRunning()
        captureSession = nil
    }

    // Calibrate (placeholder)
    func calibrate() {
        let alert = NSAlert()
        alert.messageText = "Blink Calibration"
        alert.informativeText = "Blink in a certain pattern to calibrate. Then click OK."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            isCalibrated = true
        }
    }

    // Called when user wants to map double-blink to a new hotkey
    func mapDoubleBlinkToHotkey(_ setting: BlinkHotkeySettings, context: ModelContext) {
        // Toggle between two example hotkeys for demonstration
        if setting.doubleBlinkHotkey == "⌘N" {
            setting.doubleBlinkHotkey = "⌘Q"
        } else {
            setting.doubleBlinkHotkey = "⌘N"
        }

        // Save the new hotkey in SwiftData
        do {
            try context.save()
        } catch {
            print("Error saving new hotkey: \(error)")
        }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard isDetectionEnabled else { return }

        // Convert sampleBuffer to CVPixelBuffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Here you'd run your Vision-based blink detection or custom code
        // If you detect a "double blink," you'd trigger the mapped hotkey
        // e.g., simulateKeyPress("⌘N") or AppleScript
    }

    // MARK: - Private
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        // Use front camera if available
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .front) else {
            print("No front camera found.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error creating video device input: \(error)")
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        let queue = DispatchQueue(label: "cameraQueue")
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        self.videoOutput = videoOutput
    }
}
