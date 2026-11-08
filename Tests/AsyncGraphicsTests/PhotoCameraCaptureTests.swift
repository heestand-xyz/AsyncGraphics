//
//  PhotoCameraCaptureTests.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

import Foundation
import Testing
import AVFoundation
@testable import AsyncGraphics

/// Photo Camera Capture
///
/// Skip when not needed.
/// Comment the `@Suite` and `@Test`.
//@Suite("Photo Camera Capture")
struct PhotoCameraCaptureTests {

    //@Test("Capture photo with camera")
    func capturePhotoWithCamera() async throws {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        guard let device = session.devices.first else {
            print("No camera device found for test")
            return
        }
        print("Testing camera capture with device: \(device.localizedName), id: \(device.uniqueID)")
        print("Device isAdjustingExposure: \(device.isAdjustingExposure), isAdjustingWhiteBalance: \(device.isAdjustingWhiteBalance)")
        
        let start: ContinuousClock.Instant = .now
        let graphic = try await Graphic.capturePhoto(device: device, onReady: {
            print("onReady called after \(ContinuousClock.now - start)")
        })
        print("Captured after \(ContinuousClock.now - start)")
        print("Captured graphic resolution: \(graphic.resolution), bits: \(graphic.bits), colorSpace: \(graphic.colorSpace)")
        let firstPixel = try await graphic.firstPixelColor
        print("First pixel: red=\(firstPixel.red), green=\(firstPixel.green), blue=\(firstPixel.blue), alpha=\(firstPixel.alpha)")
        
        let centerPixel = try await graphic.averagePixelColor
        print("Average pixel: red=\(centerPixel.red), green=\(centerPixel.green), blue=\(centerPixel.blue), alpha=\(centerPixel.alpha)")
        print("First pixel brightness: \(firstPixel.brightness), Average pixel brightness: \(centerPixel.brightness)")
        #expect(graphic.resolution.width > 0)
        #expect(graphic.resolution.height > 0)
    }
}
