//
//  PhotoCamera+Configuration.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(iOS) || os(macOS)
import Foundation
@preconcurrency import AVKit

extension Graphic.PhotoCamera {
    func setup(_ device: AVCaptureDevice, preset: AVCaptureSession.Preset) throws(PhotoCameraError) {
        let session: AVCaptureSession = AVCaptureSession()
        captureSession = session
        camera = device
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        if session.canSetSessionPreset(preset) {
            session.sessionPreset = preset
        } else if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        } else {
            throw .sessionPresetNotSupported
        }
#if os(iOS)
        session.automaticallyConfiguresCaptureDeviceForWideColor = true
#endif

        let input: AVCaptureDeviceInput
        do { input = try AVCaptureDeviceInput(device: device) }
        catch { throw .captureDeviceInputFailure(error) }
        guard session.canAddInput(input) else { throw .canNotAddInput }
        session.addInput(input)
        self.input = input

        let output: AVCapturePhotoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(output) else { throw .canNotAddOutput }
        session.addOutput(output)
        if #available(anyAppleOS 26.0, *) {
            // Photo outputs defer startup by default in apps linked against iOS 26.
            // This headless session needs the camera ready for focusing before the
            // capture request, and has no preview to trigger deferred startup.
            output.isDeferredStartEnabled = false
        }
        self.output = output
#if os(macOS)
        try addExposureObserver(to: session)
#endif
        output.maxPhotoQualityPrioritization = .quality
        if device.isFocusPointOfInterestSupported {
            previousFocus = (device.focusMode, device.focusPointOfInterest)
        } else {
            previousFocus = (device.focusMode, CGPoint(x: 0.5, y: 0.5))
        }
    }

    func settings(
        device: AVCaptureDevice,
        output: AVCapturePhotoOutput,
        exposureOffsets: [Float]?
    ) throws(PhotoCameraError) -> AVCapturePhotoSettings {
        let codec: AVVideoCodecType
        if output.availablePhotoCodecTypes.contains(.hevc) {
            codec = .hevc
        } else if output.availablePhotoCodecTypes.contains(.jpeg) {
            codec = .jpeg
        } else {
            throw .photoCodecNotSupported
        }
        let settings: AVCapturePhotoSettings
#if os(iOS)
        if let exposureOffsets {
            do {
                try PhotoCaptureValidation.exposureOffsets(
                    exposureOffsets,
                    maximumCount: output.maxBracketedCapturePhotoCount,
                    supportedRange: device.minExposureTargetBias...device.maxExposureTargetBias
                )
            } catch {
                switch error {
                case .tooManyBracketedPhotos(let maximum): throw .tooManyBracketedPhotos(maximum: maximum)
                case .bracketedCaptureNotSupported: throw .bracketedCaptureNotSupported
                default: throw .invalidExposureOffsets
                }
            }
            let exposures: [AVCaptureBracketedStillImageSettings] = exposureOffsets.map {
                AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(exposureTargetBias: $0)
            }
            let bracket: AVCapturePhotoBracketSettings = AVCapturePhotoBracketSettings(
                rawPixelFormatType: 0,
                processedFormat: [AVVideoCodecKey: codec],
                bracketedSettings: exposures
            )
            bracket.isLensStabilizationEnabled = output.isLensStabilizationDuringBracketedCaptureSupported
            settings = bracket
        } else {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: codec])
            settings.photoQualityPrioritization = .quality
        }
#else
        if exposureOffsets != nil {
            throw .bracketedCaptureNotSupported
        }
        settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: codec])
        settings.photoQualityPrioritization = .quality
#endif
        if let dimensions: CMVideoDimensions = device.activeFormat.supportedMaxPhotoDimensions.max(by: {
            Int64($0.width) * Int64($0.height) < Int64($1.width) * Int64($1.height)
        }) {
            output.maxPhotoDimensions = dimensions
            settings.maxPhotoDimensions = dimensions
        }
#if os(iOS)
        if #available(iOS 18.0, *), output.isShutterSoundSuppressionSupported {
            settings.isShutterSoundSuppressionEnabled = true
        }
#endif
        return settings
    }

    static func validateFocusPoint(_ point: CGPoint?) throws(PhotoCameraError) {
        do { try PhotoCaptureValidation.focusPoint(point) }
        catch { throw .invalidFocusPoint }
    }

    static func selectedFocusPoint(_ point: CGPoint?, autoFocus: Bool) throws(PhotoCameraError) -> CGPoint? {
        do { return try PhotoCaptureValidation.selectedFocusPoint(point, autoFocus: autoFocus) }
        catch { throw .invalidFocusPoint }
    }

    func cleanupSession() throws(PhotoCameraError) {
        captureSession?.stopRunning()
        defer {
            if let session: AVCaptureSession = captureSession {
                session.beginConfiguration()
                if let output { session.removeOutput(output) }
#if os(macOS)
                if let exposureOutput { session.removeOutput(exposureOutput) }
#endif
                if let input { session.removeInput(input) }
                session.commitConfiguration()
            }
            input = nil
            output = nil
#if os(macOS)
            exposureOutput = nil
            exposureObserver = nil
#endif
            captureSession = nil
            camera = nil
            previousFocus = nil
        }
        if let device: AVCaptureDevice = camera, let previousFocus {
            do { try device.lockForConfiguration() }
            catch { throw .configureOfCameraFailed }
            defer { device.unlockForConfiguration() }
            if device.isFocusPointOfInterestSupported { device.focusPointOfInterest = previousFocus.point }
            if device.isFocusModeSupported(previousFocus.mode) {
                device.focusMode = previousFocus.mode
            }
        }
    }
}
#endif
