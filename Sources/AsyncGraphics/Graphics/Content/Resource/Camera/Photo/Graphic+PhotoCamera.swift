//
//  PhotoCamera.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-11-15.
//

#if os(iOS)

import Foundation
import CoreImage
import Metal
import TextureMap
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
            focusPoint: CGPoint? = nil,
            preserveHDR: Bool = false
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
            let usesCaptureOrientation = await configureOrientation(of: output, device: device, orientation: orientation)
            let codec: AVVideoCodecType = output.availablePhotoCodecTypes.contains(.hevc) ? .hevc : .jpeg
            let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: codec])
            output.maxPhotoQualityPrioritization = .quality
            photoSettings.photoQualityPrioritization = .quality
            if #available(iOS 16.0, *),
               let dimensions = device.activeFormat.supportedMaxPhotoDimensions.max(by: {
                   Int64($0.width) * Int64($0.height) < Int64($1.width) * Int64($1.height)
               }) {
                output.maxPhotoDimensions = dimensions
                photoSettings.maxPhotoDimensions = dimensions
            }
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
            
            var capturedData: Data?
            helper.capturedData = { data in
                capturedData = data
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
            
            guard let capturedData else {
                await cleanup()
                throw .noImageCapture
            }
            
            var graphic: Graphic
            do {
                if preserveHDR {
                    graphic = try await hdrGraphic(from: capturedData)
                } else if let image = UIImage(data: capturedData) {
                    graphic = try await .image(image)
                } else {
                    throw PhotoCameraError.noImageCapture
                }
                if !usesCaptureOrientation {
                    graphic = try await orient(graphic: graphic, at: orientation)
                }
            } catch {
                await cleanup()
                throw .imageConversionToGraphicFailed(error)
            }
            
            await cleanup()
            return graphic
        }
        
        // MARK: - HDR Decoding

        private func hdrGraphic(from data: Data) async throws -> Graphic {
            guard let image = CIImage(data: data, options: [
                .applyOrientationProperty: true,
                .expandToHDR: true
            ]), let colorSpace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3) else {
                throw PhotoCameraError.noImageCapture
            }
            // Float textures retain gain-map highlights above 1.0.
            let texture: MTLTexture = try .empty(resolution: image.extent.size, bits: ._16, usage: .write)
            let context = CIContext(mtlDevice: Renderer.metalDevice)
            context.render(image, to: texture, commandBuffer: nil, bounds: image.extent, colorSpace: colorSpace)
            let graphic = Graphic(name: "Photo", texture: texture, bits: ._16, colorSpace: .custom(colorSpace))
            // Core Image renders with a bottom-left origin; Graphic uses a top-left origin.
            return try await graphic.mirroredVertically()
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
            
            let usesCaptureOrientation = await configureOrientation(of: output, device: device, orientation: orientation)
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
                    if !usesCaptureOrientation {
                        graphic = try await orient(graphic: graphic, at: orientation)
                    }
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
        
        @MainActor
        private func configureOrientation(
            of output: AVCapturePhotoOutput,
            device: AVCaptureDevice,
            orientation: UIDeviceOrientation
        ) -> Bool {
#if targetEnvironment(macCatalyst)
            return false
#else
            guard #available(iOS 27.0, *),
                  let connection = output.connection(with: .video) else { return false }
            let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: nil)
            let angle: CGFloat
            if let captureOrientation = CameraOrientation.captureOrientation(for: orientation) {
                angle = coordinator.videoRotationAngleRelative(toDeviceOrientation: captureOrientation)
            } else {
                // Face-up/down and unknown have no device-orientation equivalent.
                angle = coordinator.videoRotationAngleForHorizonLevelCapture
            }
            guard connection.isVideoRotationAngleSupported(angle) else { return false }
            // Photo output writes EXIF orientation rather than rotating pixels.
            // Both UIImage and the HDR Core Image decoder apply that metadata.
            connection.videoRotationAngle = angle
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = false
            }
            return true
#endif
        }

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
        var capturedData: ((Data) -> Void)?
        var captureDone: ((Error?) -> Void)?
        private var processingError: Error?
        
        func photoOutput(
            _ output: AVCapturePhotoOutput,
            didFinishProcessingPhoto photo: AVCapturePhoto,
            error: Error?
        ) {
            if let error {
                processingError = error
                return
            }
            if let imageData: Data = photo.fileDataRepresentation() {
                capturedData?(imageData)
                if capturedImage != nil, let image: UIImage = UIImage(data: imageData) {
                    capturedImage?(image)
                }
            }
        }
        
        func photoOutput(
            _ output: AVCapturePhotoOutput,
            didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
            error: Error?
        ) {
            captureDone?(error ?? processingError)
        }
    }
}

#endif
