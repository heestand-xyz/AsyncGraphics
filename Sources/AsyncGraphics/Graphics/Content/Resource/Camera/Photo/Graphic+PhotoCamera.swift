//
//  Graphic+PhotoCamera.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-11-15.
//

#if os(iOS) || os(macOS)
import Foundation
@preconcurrency import AVKit

extension Graphic {
    public actor PhotoCamera: Sendable {
        private nonisolated let executor: PhotoCameraExecutor = PhotoCameraExecutor()
        public nonisolated var unownedExecutor: UnownedSerialExecutor { executor.asUnownedSerialExecutor() }

        public internal(set) var captureSession: AVCaptureSession?
        public internal(set) var camera: AVCaptureDevice?
        public internal(set) var input: AVCaptureInput?
        public internal(set) var output: AVCapturePhotoOutput?

        var previousFocus: (mode: AVCaptureDevice.FocusMode, point: CGPoint)?
#if os(macOS)
        var exposureOutput: AVCaptureVideoDataOutput?
        var exposureObserver: PhotoCaptureExposureObserver?
#endif
        private var isCapturing: Bool = false
        private var cancellationRequested: Bool = false
        private var cleanupWaiters: [CheckedContinuation<Void, Never>] = []
        private static let nativeCaptureTimeout: Duration = .seconds(60)

        public init() {}

        /// Captures one photo after one-shot focusing. Automatic focus ignores the
        /// supplied point; otherwise the camera focuses at that point (or the center).
        /// Focus remains locked through capture. Simultaneous operations are rejected.
        public nonisolated(nonsending) func capture(
            for device: AVCaptureDevice,
            at preset: AVCaptureSession.Preset = .photo,
            focusPoint: CGPoint? = nil,
            autoFocus: Bool = true,
            preserveHDR: Bool = false,
            onReady: (@Sendable () async throws -> Void)? = nil
        ) async throws(PhotoCameraError) -> Graphic {
            let deviceID: String = device.uniqueID
            return try await capture(
                deviceID: deviceID, at: preset,
                focusPoint: focusPoint, autoFocus: autoFocus, preserveHDR: preserveHDR,
                onReady: onReady
            )
        }

#if os(iOS)
        /// Delivers each photo once in exposure-offset order, with a zero-based index.
        /// `onReady` runs after validation and focus, immediately before capture.
        /// Cancellation or callback failure drains native capture before returning.
        public nonisolated(nonsending) func captureBracketed(
            for device: AVCaptureDevice,
            at preset: AVCaptureSession.Preset = .photo,
            exposureOffsets: [Float] = [-1.0, 0.0, 1.0],
            focusPoint: CGPoint? = nil,
            autoFocus: Bool = true,
            preserveHDR: Bool = false,
            onReady: (@Sendable () async throws -> Void)? = nil,
            onPhoto: (@Sendable (_ index: Int, _ graphic: Graphic) async throws -> Void)? = nil
        ) async throws(PhotoCameraError) -> [Graphic] {
            let deviceID: String = device.uniqueID
            return try await captureBracketed(
                deviceID: deviceID, at: preset, exposureOffsets: exposureOffsets,
                focusPoint: focusPoint, autoFocus: autoFocus, preserveHDR: preserveHDR,
                onReady: onReady, onPhoto: onPhoto
            )
        }
#endif

        func performCapture(
            device: AVCaptureDevice,
            preset: AVCaptureSession.Preset,
            exposureOffsets: [Float]?,
            focusPoint: CGPoint?,
            autoFocus: Bool,
            preserveHDR: Bool,
            onReady: (@Sendable () async throws -> Void)?,
            onPhoto: (@Sendable (Int, Graphic) async throws -> Void)?
        ) async throws(PhotoCameraError) -> [Graphic] {
            guard !isCapturing else { throw .alreadyCapturing }
            isCapturing = true
            cancellationRequested = false
            let lease: UUID
            do {
                lease = try await PhotoCaptureAccess.shared.acquire()
            } catch {
                finishOperation()
                throw .alreadyCapturing
            }

            var result: Result<[Graphic], PhotoCameraError>
            do {
                try checkCancellation()
                let selectedFocusPoint: CGPoint? = try Self.selectedFocusPoint(focusPoint, autoFocus: autoFocus)
                if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                    let isAuthorized: Bool = await AVCaptureDevice.requestAccess(for: .video)
                    guard isAuthorized else { throw PhotoCameraError.cameraNotAuthorized }
                }
                guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                    throw PhotoCameraError.cameraNotAuthorized
                }
                try checkCancellation()
                try setup(device, preset: preset)
                guard let captureSession else { throw PhotoCameraError.captureSessionNotFound }
                guard let output else { throw PhotoCameraError.outputNotFound }
                let settings: AVCapturePhotoSettings = try settings(
                    device: device, output: output, exposureOffsets: exposureOffsets
                )
#if os(iOS)
                let deviceOrientation: UIDeviceOrientation = await MainActor.run { UIDevice.current.orientation }
                let orientation: PhotoCaptureOrientation = try configureOrientation(
                    output: output, device: device, session: captureSession, deviceOrientation: deviceOrientation,
                    focusPoint: selectedFocusPoint
                )
#else
                let orientation: PhotoCaptureOrientation = configureOrientation(
                    output: output, device: device, session: captureSession,
                    focusPoint: selectedFocusPoint
                )
#endif
                captureSession.startRunning()
                guard captureSession.isRunning else { throw PhotoCameraError.captureSessionNotRunning }
                try checkCancellation()
#if os(macOS)
                try await waitForSettledExposure()
                try checkCancellation()
#endif
                try await prepareFocus(device: device, orientation: orientation)
                try checkCancellation()
                if let onReady {
                    do { try await onReady() }
                    catch { throw PhotoCameraError.deliveryFailed(error) }
                }
                try checkCancellation()
                let graphics: [Graphic] = try await collect(
                    output: output, settings: settings,
                    expectedCount: exposureOffsets?.count ?? 1,
                    preserveHDR: preserveHDR, onPhoto: onPhoto
                )
                result = .success(graphics)
            } catch let error as PhotoCameraError {
                result = .failure(error)
            } catch {
                result = .failure(.captureFailed(error))
            }
            do {
                try cleanupSession()
            } catch {
                result = .failure(error)
            }
            await PhotoCaptureAccess.shared.release(lease)
            finishOperation()
            return try result.get()
        }

        private func collect(
            output: AVCapturePhotoOutput,
            settings: AVCapturePhotoSettings,
            expectedCount: Int,
            preserveHDR: Bool,
            onPhoto: (@Sendable (Int, Graphic) async throws -> Void)?
        ) async throws(PhotoCameraError) -> [Graphic] {
            let sequence: PhotoCaptureSequence = PhotoCaptureSequence(expectedCount: expectedCount)
            let isBracketed: Bool
#if os(iOS)
            isBracketed = settings is AVCapturePhotoBracketSettings
#else
            isBracketed = false
#endif
            let delegate: PhotoCaptureDelegate = PhotoCaptureDelegate(sequence: sequence, isBracketed: isBracketed)
            let recoveryTask: Task<Void, Never> = Task(name: "Graphic.PhotoCamera: Recover Timed Out Capture") { [weak self] in
                do { try await Task.sleep(for: Self.nativeCaptureTimeout) }
                catch { return }
                await self?.recoverCaptureIfNeeded(sequence)
            }
            var graphics: [Graphic] = []
            var operationError: PhotoCameraError?
            output.capturePhoto(with: settings, delegate: delegate)
            // Keep the delegate and native capture alive through its final callback,
            // including when the requesting task or a progressive delivery is cancelled.
            while true {
                let event: PhotoCaptureSequence.Event = await sequence.next()
                if operationError == nil, Task.isCancelled || cancellationRequested {
                    operationError = .cancelled
                }
                switch event {
                case .photo(let index, let data):
                    guard operationError == nil else { continue }
                    let graphic: Graphic
                    do {
                        graphic = try await decodePhoto(data, preserveHDR: preserveHDR)
                    } catch {
                        operationError = .imageConversionToGraphicFailed(error)
                        continue
                    }
                    guard !Task.isCancelled, !cancellationRequested else {
                        operationError = .cancelled
                        continue
                    }
                    if let onPhoto {
                        do { try await onPhoto(index, graphic) }
                        catch {
                            operationError = error is CancellationError ? .cancelled : .deliveryFailed(error)
                            continue
                        }
                    }
                    graphics.append(graphic)
                case .finished(let result):
                    recoveryTask.cancel()
                    await recoveryTask.value
                    withExtendedLifetime(delegate) {}
                    if let operationError { throw operationError }
                    if case .failure(let error) = result { throw .captureFailed(error) }
                    return graphics
                }
            }
        }

        private func checkCancellation() throws(PhotoCameraError) {
            if Task.isCancelled || cancellationRequested { throw .cancelled }
        }

        private func recoverCaptureIfNeeded(_ sequence: PhotoCaptureSequence) {
            guard !sequence.isFinished else { return }
            // A missing terminal callback must never hand running hardware to the
            // next requester. Stop and detach the session before retiring callbacks.
            do {
                try cleanupSession()
                sequence.retire(error: PhotoCameraError.captureTimedOut)
            } catch {
                sequence.retire(error: error)
            }
        }

        /// Cancels publication, then waits for any native capture and resource release.
        /// It never removes an output while its delegate is still capturing.
        public func cleanup() async {
            guard isCapturing else { return }
            cancellationRequested = true
            await withCheckedContinuation { continuation in
                cleanupWaiters.append(continuation)
            }
        }

        private func finishOperation() {
            isCapturing = false
            cancellationRequested = false
            let waiters: [CheckedContinuation<Void, Never>] = cleanupWaiters
            cleanupWaiters.removeAll()
            for waiter in waiters { waiter.resume() }
        }
    }
}
#endif
