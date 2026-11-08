//
//  PhotoCamera+Focus.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-11-08.
//

#if os(iOS) || os(macOS)
import Foundation
@preconcurrency import AVKit
#if canImport(UIKit)
import UIKit
#endif

struct PhotoCaptureOrientation: Sendable {
    let deviceFocusPoint: CGPoint?
}

extension Graphic.PhotoCamera {
    private static let focusTimeout: Duration = .seconds(5)

#if os(iOS)
    func configureOrientation(
        output: AVCapturePhotoOutput,
        device: AVCaptureDevice,
        session: AVCaptureSession,
        deviceOrientation: UIDeviceOrientation,
        focusPoint: CGPoint?
    ) throws(PhotoCameraError) -> PhotoCaptureOrientation {
        guard let photoConnection: AVCaptureConnection = output.connection(with: .video) else {
            throw .captureConnectionNotFound
        }
        let captureOrientation: AVCaptureVideoOrientation =
            CameraOrientation.captureOrientation(for: deviceOrientation) ?? .portrait
        let rotationAngle: CGFloat?
#if !targetEnvironment(macCatalyst)
        if #available(iOS 27.0, *) {
            let coordinator: AVCaptureDevice.RotationCoordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: nil)
            rotationAngle = coordinator.videoRotationAngleRelative(toDeviceOrientation: captureOrientation)
        } else {
            rotationAngle = nil
        }
#else
        rotationAngle = nil
#endif
        try configureConnection(photoConnection, rotationAngle: rotationAngle, orientation: captureOrientation)
        guard let focusPoint else { return PhotoCaptureOrientation(deviceFocusPoint: nil) }

        // AVFoundation converts from the same unmirrored, oriented picture area
        // used by the photo connection, including the device's sensor mounting.
        // This temporary layer never enters a UI hierarchy or starts another session;
        // it and the AVFoundation objects stay on the photo camera's executor.
        let layer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        defer { layer.session = nil }
        layer.frame = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        layer.videoGravity = .resize
        guard let previewConnection: AVCaptureConnection = layer.connection else {
            throw .captureConnectionNotFound
        }
        try configureConnection(previewConnection, rotationAngle: rotationAngle, orientation: captureOrientation)
        let devicePoint: CGPoint = layer.captureDevicePointConverted(fromLayerPoint: focusPoint)
        try Self.validateFocusPoint(devicePoint)
        return PhotoCaptureOrientation(deviceFocusPoint: devicePoint)
    }

    private func configureConnection(
        _ connection: AVCaptureConnection,
        rotationAngle: CGFloat?,
        orientation: AVCaptureVideoOrientation
    ) throws(PhotoCameraError) {
        if let rotationAngle {
            guard connection.isVideoRotationAngleSupported(rotationAngle) else { throw .captureOrientationNotSupported }
            connection.videoRotationAngle = rotationAngle
        } else {
            guard connection.isVideoOrientationSupported else { throw .captureOrientationNotSupported }
            connection.videoOrientation = orientation
        }
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false
        }
    }
#else
    func configureOrientation(
        output: AVCapturePhotoOutput,
        device: AVCaptureDevice,
        session: AVCaptureSession,
        focusPoint: CGPoint?
    ) -> PhotoCaptureOrientation {
        PhotoCaptureOrientation(deviceFocusPoint: focusPoint)
    }
#endif

    func prepareFocus(
        device: AVCaptureDevice,
        orientation: PhotoCaptureOrientation
    ) async throws(PhotoCameraError) {
        guard device.isFocusModeSupported(.autoFocus) && device.isFocusModeSupported(.locked) else {
            if orientation.deviceFocusPoint != nil { throw .focusPointNotSupported }
            return
        }
        if orientation.deviceFocusPoint != nil, !device.isFocusPointOfInterestSupported { throw .focusPointNotSupported }

        do { try device.lockForConfiguration() }
        catch { throw .configureOfCameraFailed }
        device.focusMode = .locked
        if device.isFocusPointOfInterestSupported {
            // Automatic focus uses the camera's default picture area, independent
            // of any caller-supplied point or a previous capture's point.
            device.focusPointOfInterest = orientation.deviceFocusPoint ?? CGPoint(x: 0.5, y: 0.5)
        }
        device.focusMode = .autoFocus
        device.unlockForConfiguration()

        let events: (stream: AsyncStream<AVCaptureDevice.FocusMode>, continuation: AsyncStream<AVCaptureDevice.FocusMode>.Continuation) = AsyncStream.makeStream()
        // Observe after requesting focus and include its current state. A fast focus
        // operation may already be locked; receiving an autoFocus notification is
        // not a prerequisite. Phase detection can settle without a focus scan.
        // Read the device's mode: Swift KVO change values are nil for imported enums.
        let observation: NSKeyValueObservation = device.observe(\.focusMode, options: [.initial, .new]) { observedDevice, _ in
            events.continuation.yield(observedDevice.focusMode)
        }
        defer {
            observation.invalidate()
            events.continuation.finish()
        }

        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await mode in events.stream {
                        try Task.checkCancellation()
                        if mode == .locked { return }
                    }
                    throw CancellationError()
                }
                group.addTask {
                    try await Task.sleep(for: Self.focusTimeout)
                    throw PhotoCameraError.focusTimedOut
                }
                defer { group.cancelAll() }
                _ = try await group.next()
            }
        } catch is CancellationError {
            throw .cancelled
        } catch let error as PhotoCameraError {
            throw error
        } catch {
            throw .captureFailed(error)
        }
    }
}
#endif
