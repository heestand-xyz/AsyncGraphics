//
//  Graphic+PhotoCamera.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-11-15.
//

#if os(iOS)

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
    ///   - focusPoint: An optional normalized focus point of interest. {0,0} is the top-left of the picture area and {1,1} is the bottom-right. *The focus point will automatically be oriented base on device rotation.*
    /// - Returns: An array of graphics.
    public static func capturePhoto(
        at position: AVCaptureDevice.Position,
        lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
        quality: AVCaptureSession.Preset = .photo,
        focusPoint: CGPoint? = nil
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
            focusPoint: focusPoint
        )
    }
    
    /// Captures a photo with the specified camera.
    /// - Parameters:
    ///   - device: The camera to use.
    ///   - quality: Default to photo quality.
    ///   - focusPoint: An optional normalized focus point of interest. {0,0} is the top-left of the picture area and {1,1} is the bottom-right. *The focus point will automatically be oriented base on device rotation.*
    /// - Returns: An array of graphics.
    public static func capturePhoto(
        device: AVCaptureDevice,
        quality: AVCaptureSession.Preset = .photo,
        focusPoint: CGPoint? = nil
    ) async throws -> Graphic {
        
        let photoCamera = PhotoCamera()
        
        return try await photoCamera.capture(
            for: device,
            at: quality,
            focusPoint: focusPoint
        )
    }
    
    // MARK: - Capture Bracketed Photos
    
    /// Captures bracketed photos with a camera based on position and lens.
    /// - Parameters:
    ///   - position: Front or back camera.
    ///   - lens: Ultra wide, wide or tele camera.
    ///   - quality: Default to photo quality.
    ///   - exposureOffsets: An array of exposure target biases. Default [-1.0, 0.0, 1.0].
    ///   - focusPoint: An optional normalized focus point of interest. {0,0} is the top-left of the picture area and {1,1} is the bottom-right. *The focus point will automatically be oriented base on device rotation.*
    /// - Returns: An array of graphics.
    public static func captureBracketedPhotos(
        at position: AVCaptureDevice.Position,
        lens: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
        quality: AVCaptureSession.Preset = .photo,
        exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
        focusPoint: CGPoint? = nil
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
            focusPoint: focusPoint
        )
    }
    
    /// Captures bracketed photos with the specified camera.
    /// - Parameters:
    ///   - device: The camera to use.
    ///   - quality: Default to photo quality.
    ///   - exposureOffsets: An array of exposure target biases. Default [-1.0, 0.0, 1.0].
    ///   - focusPoint: An optional normalized focus point of interest. {0,0} is the top-left of the picture area and {1,1} is the bottom-right. *The focus point will automatically be oriented base on device rotation.*
    /// - Returns: An array of graphics.
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
}

#endif
