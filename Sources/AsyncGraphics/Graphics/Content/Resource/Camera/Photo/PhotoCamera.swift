//
//  Graphic+PhotoCamera.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-11-15.
//

#if os(iOS) || os(macOS)

import AVKit

extension Graphic {
    
    enum PhotoCaptureError: LocalizedError {
        case cameraNotFound
        var errorDescription: String? {
            switch self {
            case .cameraNotFound:
                "Camera not found."
            }
        }
    }
    
    // MARK: - Capture Photo
    
    /// Captures a photo with a camera based on position and lens.
    /// - Parameters:
    ///   - position: Front or back camera.
    ///   - lens: Ultra wide, wide or tele camera.
    ///   - quality: Default to photo quality.
    ///   - focusPoint: A normalized point in the oriented, unmirrored photo (front-camera output is mirrored after capture), with x right and y down. The top-left is {0,0} and bottom-right is {1,1}.
    ///   - autoFocus: True uses automatic focus and ignores focusPoint. False focuses once at focusPoint (or the center). Both modes lock focus through capture.
    ///   - preserveHDR: Decode the original photo bytes into a 16-bit float graphic, preserving available HDR gain maps. Defaults to false.
    ///   - onReady: Runs after validation and focus, immediately before capture starts.
    /// - Returns: The captured graphic.
    public static func capturePhoto(
        at position: AVCaptureDevice.Position,
        lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
        quality: AVCaptureSession.Preset = .photo,
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil
    ) async throws -> Graphic {

        guard let device: AVCaptureDevice = .default(
            lens,
            for: .video,
            position: position
        ) else {
            throw PhotoCaptureError.cameraNotFound
        }

        return try await capturePhoto(
            device: device,
            quality: quality,
            focusPoint: focusPoint,
            autoFocus: autoFocus,
            preserveHDR: preserveHDR,
            onReady: onReady
        )
    }
    
    /// Captures a photo with the specified camera.
    /// - Parameters:
    ///   - device: The camera to use.
    ///   - quality: Default to photo quality.
    ///   - focusPoint: A normalized point in the oriented, unmirrored photo (front-camera output is mirrored after capture), with x right and y down. The top-left is {0,0} and bottom-right is {1,1}.
    ///   - autoFocus: True uses automatic focus and ignores focusPoint. False focuses once at focusPoint (or the center). Both modes lock focus through capture.
    ///   - preserveHDR: Decode the original photo bytes into a 16-bit float graphic, preserving available HDR gain maps. Defaults to false.
    ///   - onReady: Runs after validation and focus, immediately before capture starts.
    /// - Returns: The captured graphic.
    public nonisolated(nonsending) static func capturePhoto(
        device: AVCaptureDevice,
        quality: AVCaptureSession.Preset = .photo,
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil
    ) async throws -> Graphic {
        
        let deviceID: String = device.uniqueID
        return try await capturePhoto(
            deviceID: deviceID,
            quality: quality,
            focusPoint: focusPoint,
            autoFocus: autoFocus,
            preserveHDR: preserveHDR,
            onReady: onReady
        )
    }
    
#if os(iOS)
    // MARK: - Capture Bracketed Photos
    
    /// Captures bracketed photos with a camera based on position and lens.
    /// - Parameters:
    ///   - position: Front or back camera.
    ///   - lens: Ultra wide, wide or tele camera.
    ///   - quality: Default to photo quality.
    ///   - exposureOffsets: An array of exposure target biases. Default [-1.0, 0.0, 1.0].
    ///   - focusPoint: A normalized point in the oriented, unmirrored photo (front-camera output is mirrored after capture), with x right and y down. The top-left is {0,0} and bottom-right is {1,1}.
    ///   - autoFocus: True uses automatic focus and ignores focusPoint. False focuses once at focusPoint (or the center). Both modes lock focus through capture.
    ///   - preserveHDR: Decode each original photo into a 16-bit float graphic, preserving available HDR gain maps.
    ///   - onReady: Runs once after validation and focus, immediately before capture starts.
    ///   - onPhoto: Receives each photo in exposure-offset order with a zero-based index. Cancellation or callback failure waits for native capture cleanup before returning.
    /// - Returns: All captured graphics in exposure-offset order.
    public static func captureBracketedPhotos(
        at position: AVCaptureDevice.Position,
        lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
        quality: AVCaptureSession.Preset = .photo,
        exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil,
        onPhoto: (@Sendable (_ index: Int, _ graphic: Graphic) async throws -> Void)? = nil
    ) async throws -> [Graphic] {

        guard let device: AVCaptureDevice = .default(
            lens,
            for: .video,
            position: position
        ) else {
            throw PhotoCaptureError.cameraNotFound
        }

        return try await captureBracketedPhotos(
            device: device,
            quality: quality,
            exposureOffsets: exposureOffsets,
            focusPoint: focusPoint,
            autoFocus: autoFocus,
            preserveHDR: preserveHDR,
            onReady: onReady,
            onPhoto: onPhoto
        )
    }
    
    /// Captures bracketed photos with the specified camera.
    /// - Parameters:
    ///   - device: The camera to use.
    ///   - quality: Default to photo quality.
    ///   - exposureOffsets: An array of exposure target biases. Default [-1.0, 0.0, 1.0].
    ///   - focusPoint: A normalized point in the oriented, unmirrored photo (front-camera output is mirrored after capture), with x right and y down. The top-left is {0,0} and bottom-right is {1,1}.
    ///   - autoFocus: True uses automatic focus and ignores focusPoint. False focuses once at focusPoint (or the center). Both modes lock focus through capture.
    ///   - preserveHDR: Decode each original photo into a 16-bit float graphic, preserving available HDR gain maps.
    ///   - onReady: Runs once after validation and focus, immediately before capture starts.
    ///   - onPhoto: Receives each photo in exposure-offset order with a zero-based index. Cancellation or callback failure waits for native capture cleanup before returning.
    /// - Returns: All captured graphics in exposure-offset order.
    public nonisolated(nonsending) static func captureBracketedPhotos(
        device: AVCaptureDevice,
        quality: AVCaptureSession.Preset = .photo,
        exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
        focusPoint: CGPoint? = nil,
        autoFocus: Bool = true,
        preserveHDR: Bool = false,
        onReady: (@Sendable () async throws -> Void)? = nil,
        onPhoto: (@Sendable (_ index: Int, _ graphic: Graphic) async throws -> Void)? = nil
    ) async throws -> [Graphic] {
        
        let deviceID: String = device.uniqueID
        return try await captureBracketedPhotos(
            deviceID: deviceID,
            quality: quality,
            exposureOffsets: exposureOffsets,
            focusPoint: focusPoint,
            autoFocus: autoFocus,
            preserveHDR: preserveHDR,
            onReady: onReady,
            onPhoto: onPhoto
        )
    }
#endif
}

#endif
