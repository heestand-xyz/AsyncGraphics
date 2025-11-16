//
//  PhotoCamera.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-11-15.
//

#if os(iOS)

import Foundation
@preconcurrency import AVKit

extension Graphic {
    
    actor PhotoCamera: Sendable {
        
        private var captureSession: AVCaptureSession?
        private var camera: AVCaptureDevice?
        private var input: AVCaptureInput?
        private var output: AVCapturePhotoOutput?
        
        private var captureContinuation: CheckedContinuation<[UIImage], Error>?
        
        enum PhotoCameraError: LocalizedError {
            case sessionPresetNotSupported
            case canNotAddOutput
            case canNotAddInput
            case captureSessionNotFound
            case outputNotFound
            case inputNotFound
            case captureDeviceInputFailure(Error)
            case imageConversionToGraphicFailed(Error)
            case configureOfCameraFailed
            case noImageCapture
            case captureFailed(Error)
            case cancelled
            var errorDescription: String? {
                switch self {
                case .sessionPresetNotSupported:
                    "Photo Camera - Session preset not supported."
                case .canNotAddOutput:
                    "Photo Camera - Can not add output."
                case .canNotAddInput:
                    "Photo Camera - Can not add input."
                case .captureSessionNotFound:
                    "Photo Camera - Capture session not found."
                case .outputNotFound:
                    "Photo Camera - Output not found."
                case .inputNotFound:
                    "Photo Camera - Input not found."
                case .captureDeviceInputFailure(let error):
                    "Photo Camera - Capture device input failure: \(error.localizedDescription)"
                case .imageConversionToGraphicFailed(let error):
                    "Photo Camera - Image conversion to graphic failed: \(error.localizedDescription)"
                case .configureOfCameraFailed:
                    "Photo Camera - Configure of camera failed."
                case .noImageCapture:
                    "Photo Camera - No image capture."
                case .captureFailed(let error):
                    "Photo Camera - Capture failed: \(error.localizedDescription)"
                case .cancelled:
                    "Photo Camera - Cancelled"
                }
            }
        }
        
        public init() {}
        
        // MARK: - Setup
        
        private func setup(
            _ device: AVCaptureDevice,
            preset: AVCaptureSession.Preset
        ) throws(PhotoCameraError) {
            
            let captureSession = AVCaptureSession()
            
            captureSession.beginConfiguration()
            defer {
                captureSession.commitConfiguration()
            }
            
            guard captureSession.canSetSessionPreset(preset) else {
                throw .sessionPresetNotSupported
            }
            captureSession.sessionPreset = preset
            captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            try setupInput(for: device, to: captureSession)
            try addOutput(to: captureSession)
            
            self.captureSession = captureSession
        }
        
        private func setupInput(
            for device: AVCaptureDevice,
            to captureSession: AVCaptureSession
        ) throws(PhotoCameraError) {
            let input: AVCaptureDeviceInput
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch {
                throw .captureDeviceInputFailure(error)
            }
            guard captureSession.canAddInput(input) else {
                throw .canNotAddInput
            }
            captureSession.addInput(input)
            self.input = input
        }
        
        private func addOutput(
            to captureSession: AVCaptureSession
        ) throws(PhotoCameraError) {
            let output = AVCapturePhotoOutput()
            guard captureSession.canAddOutput(output) else {
                throw .canNotAddOutput
            }
            captureSession.addOutput(output)
            self.output = output
        }
        
        // MARK: - Capture
        
        @concurrent func capture(
            for device: AVCaptureDevice,
            at preset: AVCaptureSession.Preset,
            focusPoint: CGPoint? = nil
        ) async throws(PhotoCameraError) -> Graphic {
            
            let orientation: UIDeviceOrientation = await UIDevice.current.orientation
            
            do {
                try await setup(device, preset: preset)
            } catch {
                await cleanup()
                throw error
            }
            
            guard let captureSession: AVCaptureSession = await captureSession else {
                await cleanup()
                throw .captureSessionNotFound
            }
            
            guard let output: AVCapturePhotoOutput = await output else {
                await cleanup()
                throw .outputNotFound
            }
            let photoSettings = AVCapturePhotoSettings(
                rawPixelFormatType: 0,
                processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc]
            )
            if #available(iOS 18.0, *), output.isShutterSoundSuppressionSupported {
                photoSettings.isShutterSoundSuppressionEnabled = true
            }
            
            if let focusPoint, device.isFocusPointOfInterestSupported {
                do {
                    try device.lockForConfiguration()
                } catch {
                    await cleanup()
                    throw .configureOfCameraFailed
                }
                device.focusPointOfInterest = await orient(point: focusPoint, at: orientation)
                device.focusMode = .locked
                device.unlockForConfiguration()
            }
            
            if Task.isCancelled {
                await cleanup()
                throw .cancelled
            }
            
            let helper = Helper()
            
            var capturedImages: [UIImage] = []
            helper.capturedImage = { image in
                capturedImages.append(image)
            }
            
            let captureError: Error? = await withCheckedContinuation { continuation in
                helper.captureDone = { error in
                    continuation.resume(returning: error)
                }
                captureSession.startRunning()
                output.capturePhoto(with: photoSettings, delegate: helper)
            }
            
            if let captureError {
                await cleanup()
                throw .captureFailed(captureError)
            }
            
            guard let capturedImage: UIImage = capturedImages.first else {
                throw .noImageCapture
            }
            
            var graphic: Graphic
            do {
                graphic = try await .image(capturedImage)
                graphic = try await orient(graphic: graphic, at: orientation)
            } catch {
                await cleanup()
                throw .imageConversionToGraphicFailed(error)
            }
            
            await cleanup()
            return graphic
        }
        
        // MARK: - Capture Bracketed
        
        @concurrent func captureBracketed(
            for device: AVCaptureDevice,
            at preset: AVCaptureSession.Preset,
            exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
            focusPoint: CGPoint? = nil
        ) async throws(PhotoCameraError) -> [Graphic] {

            let orientation: UIDeviceOrientation = await UIDevice.current.orientation

            do {
                try await setup(device, preset: preset)
            } catch {
                await cleanup()
                throw error
            }
            
            guard let captureSession: AVCaptureSession = await captureSession else {
                await cleanup()
                throw .captureSessionNotFound
            }
            
            guard let output: AVCapturePhotoOutput = await output else {
                await cleanup()
                throw .outputNotFound
            }
            
            let exposureSettings = exposureOffsets.map {
                AVCaptureAutoExposureBracketedStillImageSettings
                    .autoExposureSettings(exposureTargetBias: $0)
            }
            
            let photoSettings = AVCapturePhotoBracketSettings(
                rawPixelFormatType: 0,
                processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc],
                bracketedSettings: exposureSettings
            )
            if #available(iOS 18.0, *), output.isShutterSoundSuppressionSupported {
                photoSettings.isShutterSoundSuppressionEnabled = true
            }
            photoSettings.isLensStabilizationEnabled = output.isLensStabilizationDuringBracketedCaptureSupported
            
            if let focusPoint, device.isFocusPointOfInterestSupported {
                do {
                    try device.lockForConfiguration()
                } catch {
                    await cleanup()
                    throw .configureOfCameraFailed
                }
                device.focusPointOfInterest = await orient(point: focusPoint, at: orientation)
                device.focusMode = .locked
                device.unlockForConfiguration()
            }
            
            if Task.isCancelled {
                await cleanup()
                throw .cancelled
            }
            
            let helper = Helper()
            
            var capturedImages: [UIImage] = []
            helper.capturedImage = { image in
                capturedImages.append(image)
            }
                        
            let captureError: Error? = await withCheckedContinuation { continuation in
                helper.captureDone = { error in
                    continuation.resume(returning: error)
                }
                captureSession.startRunning()
                output.capturePhoto(with: photoSettings, delegate: helper)
            }
            
            if let captureError {
                await cleanup()
                throw .captureFailed(captureError)
            }
            
            var graphics: [Graphic] = []
            do {
                for image in capturedImages {
                    var graphic: Graphic = try await .image(image)
                    graphic = try await orient(graphic: graphic, at: orientation)
                    graphics.append(graphic)
                }
            } catch {
                await cleanup()
                throw .imageConversionToGraphicFailed(error)
            }
            
            await cleanup()
            return graphics
        }
        
        // MARK: - Orient
        
        private func orient(graphic: Graphic, at orientation: UIDeviceOrientation) async throws -> Graphic {
            switch orientation {
            case .landscapeLeft:
                try await graphic.rotatedLeft()
            case .landscapeRight:
                try await graphic.rotatedRight()
            case .portraitUpsideDown:
                try await graphic.rotated(.degrees(180))
            default:
                graphic
            }
        }
        
        private func orient(point: CGPoint, at orientation: UIDeviceOrientation) -> CGPoint {
            switch orientation {
            case .landscapeLeft:
                point
            case .landscapeRight:
                CGPoint(x: 1.0 - point.x, y: 1.0 - point.y)
            case .portraitUpsideDown:
                CGPoint(x: 1.0 - point.y, y: point.x)
            default:
                CGPoint(x: point.y, y: 1.0 - point.x)
            }
        }
        
        // MARK: - Cleanup
        
        private func cleanup() {
            if let input {
                captureSession?.removeInput(input)
                self.input = nil
            }
            if let output {
                captureSession?.removeOutput(output)
                self.output = nil
            }
            captureSession?.stopRunning()
            captureSession = nil
        }
    }
}

// MARK: - Capture Delegate

extension Graphic.PhotoCamera {
    
    final class Helper: NSObject, AVCapturePhotoCaptureDelegate {
        
        var capturedImage: ((UIImage) -> Void)?
        var captureDone: ((Error?) -> Void)?
        
        func photoOutput(
            _ output: AVCapturePhotoOutput,
            didFinishProcessingPhoto photo: AVCapturePhoto,
            error: Error?
        ) {
            if let imageData: Data = photo.fileDataRepresentation() {
                if let image: UIImage = UIImage(data: imageData){
                    capturedImage?(image)
                }
            }
        }
        
        func photoOutput(
            _ output: AVCapturePhotoOutput,
            didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
            error: Error?
        ) {
            captureDone?(error)
        }
    }
}

#endif
