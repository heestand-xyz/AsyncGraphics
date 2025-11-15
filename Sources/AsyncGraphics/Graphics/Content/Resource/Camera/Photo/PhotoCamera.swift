//
//  Graphic+PhotoCamera.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-11-15.
//

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
    
#if !os(visionOS)
    /// Captures bracketed photos with the specified camera.
    public static func captureBracketedPhotos(
        device: AVCaptureDevice,
        quality: AVCaptureSession.Preset = .photo,
        exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
        focusPoint: CGPoint? = nil
    ) async throws -> [Graphic] {
        
        let photoCamera = PhotoCamera()
        
        return try await photoCamera.captureBracketed(
            for: device,
            at: quality,
            exposureOffsets: exposureOffsets,
            focusPoint: focusPoint
        )
    }
    
    /// Captures bracketed photos with a camera based on position and lens.
    public static func captureBracketedPhotos(
        at position: CameraPosition = .front,
        lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
        quality: AVCaptureSession.Preset = .photo,
        exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
        focusPoint: CGPoint? = nil
    ) async throws -> [Graphic] {

        guard let device: AVCaptureDevice = .default(
            lens,
            for: .video,
            position: position.av
        ) else {
            throw PhotoCaptureError.cameraNotFound
        }

        return try await captureBracketedPhotos(
            device: device,
            quality: quality,
            exposureOffsets: exposureOffsets,
            focusPoint: focusPoint
        )
    }
#endif
}
