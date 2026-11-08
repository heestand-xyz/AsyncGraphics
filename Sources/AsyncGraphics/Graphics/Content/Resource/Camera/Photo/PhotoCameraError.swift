//
//  PhotoCameraError.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(iOS) || os(macOS)
import Foundation

extension Graphic.PhotoCamera {
    public enum PhotoCameraError: LocalizedError {
        case sessionPresetNotSupported
        case canNotAddOutput
        case canNotAddInput
        case captureSessionNotFound
        case outputNotFound
        case inputNotFound
        case captureDeviceInputFailure(any Error)
        case captureDeviceNotFound
        case imageConversionToGraphicFailed(any Error)
        case configureOfCameraFailed
        case noImageCapture
        case captureFailed(any Error)
        case cancelled
        case alreadyCapturing
        case cameraNotAuthorized
        case captureSessionNotRunning
        case captureTimedOut
        case photoCodecNotSupported
        case captureConnectionNotFound
        case captureOrientationNotSupported
        case invalidFocusPoint
        case focusPointNotSupported
        case autoFocusNotSupported
        case focusLockNotSupported
        case focusTimedOut
        case exposureTimedOut
        case invalidExposureOffsets
        case tooManyBracketedPhotos(maximum: Int)
        case bracketedCaptureNotSupported
        case deliveryFailed(any Error)

        public var errorDescription: String? {
            switch self {
            case .sessionPresetNotSupported: "Choose a photo quality supported by this camera."
            case .canNotAddOutput: "The camera cannot add a photo output. Stop other capture sessions and try again."
            case .canNotAddInput: "The camera cannot add an input. Stop other capture sessions and try again."
            case .captureSessionNotFound: "The photo capture session is unavailable. Try capturing again."
            case .outputNotFound: "The photo output is unavailable. Try capturing again."
            case .inputNotFound: "The camera input is unavailable. Choose a camera and try again."
            case .captureDeviceInputFailure(let error): "The camera input could not be opened: \(error.localizedDescription)"
            case .captureDeviceNotFound: "The selected camera is no longer available. Reconnect it or choose another camera."
            case .imageConversionToGraphicFailed(let error): "The captured photo could not be decoded: \(error.localizedDescription)"
            case .configureOfCameraFailed: "The camera settings could not be changed. Stop other capture sessions and try again."
            case .noImageCapture: "The camera did not return a photo. Try capturing again."
            case .captureFailed(let error): "The camera could not complete the photo capture: \(error.localizedDescription)"
            case .cancelled: "The photo capture was cancelled."
            case .alreadyCapturing: "Another photo capture is in progress. Wait for it to finish and try again."
            case .cameraNotAuthorized: "Allow camera access in Settings before capturing a photo."
            case .captureSessionNotRunning: "The photo camera could not start. Stop other capture sessions and try again."
            case .captureTimedOut: "The camera did not finish capturing in time. Its session was stopped; try capturing again."
            case .photoCodecNotSupported: "This camera does not support a compatible photo format. Choose another camera."
            case .captureConnectionNotFound: "The photo camera connection is unavailable. Choose another camera and try again."
            case .captureOrientationNotSupported: "This camera does not support the requested photo orientation. Choose another camera."
            case .invalidFocusPoint: "Set both coordinates of \"Focus Point\" to finite values between 0 and 1."
            case .focusPointNotSupported: "This camera does not support a focus point. Turn on automatic focus or choose another camera."
            case .autoFocusNotSupported: "This camera does not support focusing before photo capture. Choose another camera."
            case .focusLockNotSupported: "This camera cannot lock focus for photo capture. Choose another camera."
            case .focusTimedOut: "The camera could not finish focusing. Try capturing again or choose another camera."
            case .exposureTimedOut: "The camera could not finish adjusting exposure. Try capturing again in steadier light or choose another camera."
            case .invalidExposureOffsets: "Set \"Exposure Offsets\" to a nonempty list of finite values within the camera's exposure range."
            case .tooManyBracketedPhotos(let maximum): "This camera supports at most \(maximum) bracketed photos. Reduce \"Exposure Offsets\"."
            case .bracketedCaptureNotSupported: "This camera does not support bracketed photos. Choose another camera."
            case .deliveryFailed(let error): "The captured photo could not be delivered: \(error.localizedDescription)"
            }
        }
    }
}
#endif
