//
//  PhotoCamera+DeviceID.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(iOS) || os(macOS)
import Foundation
import AVFoundation

extension Graphic.PhotoCamera {
    /// Resolves the exact selected device inside the camera's isolated executor.
    /// No discovery session or selection policy is created here.
    public func capture(
        deviceID: String,
        at preset: AVCaptureSession.Preset = .photo,
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil
    ) async throws(PhotoCameraError) -> Graphic {
        guard let device: AVCaptureDevice = AVCaptureDevice(uniqueID: deviceID) else { throw .captureDeviceNotFound }
        let graphics: [Graphic] = try await performCapture(
            device: device, preset: preset, exposureOffsets: nil,
            focusPoint: focusPoint, autoFocus: autoFocus, preserveHDR: preserveHDR,
            onReady: onReady, onPhoto: nil
        )
        guard let graphic: Graphic = graphics.first else { throw .noImageCapture }
        return graphic
    }

#if os(iOS)
    /// Captures the exact selected device with serial, exposure-ordered callbacks.
    public func captureBracketed(
        deviceID: String,
        at preset: AVCaptureSession.Preset = .photo,
        exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil,
        onPhoto: (@Sendable (_ index: Int, _ graphic: Graphic) async throws -> Void)? = nil
    ) async throws(PhotoCameraError) -> [Graphic] {
        guard let device: AVCaptureDevice = AVCaptureDevice(uniqueID: deviceID) else { throw .captureDeviceNotFound }
        return try await performCapture(
            device: device, preset: preset, exposureOffsets: exposureOffsets,
            focusPoint: focusPoint, autoFocus: autoFocus, preserveHDR: preserveHDR,
            onReady: onReady, onPhoto: onPhoto
        )
    }
#endif
}

// MARK: - Graphic Capture

extension Graphic {
    /// Captures by a validated unique device ID without transferring an
    /// AVCaptureDevice between the caller and the photo camera actor.
    public static func capturePhoto(
        deviceID: String,
        quality: AVCaptureSession.Preset = .photo,
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil
    ) async throws -> Graphic {
        let photoCamera: PhotoCamera = PhotoCamera()
        return try await photoCamera.capture(
            deviceID: deviceID, at: quality, focusPoint: focusPoint,
            autoFocus: autoFocus, preserveHDR: preserveHDR, onReady: onReady
        )
    }

#if os(iOS)
    /// Captures bracketed photos by exact device ID. Callback indices are zero-based
    /// and always follow exposure-offset order, including repeated offsets.
    public static func captureBracketedPhotos(
        deviceID: String,
        quality: AVCaptureSession.Preset = .photo,
        exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil,
        onPhoto: (@Sendable (_ index: Int, _ graphic: Graphic) async throws -> Void)? = nil
    ) async throws -> [Graphic] {
        let photoCamera: PhotoCamera = PhotoCamera()
        return try await photoCamera.captureBracketed(
            deviceID: deviceID, at: quality, exposureOffsets: exposureOffsets,
            focusPoint: focusPoint, autoFocus: autoFocus, preserveHDR: preserveHDR,
            onReady: onReady, onPhoto: onPhoto
        )
    }
#endif
}
#endif
