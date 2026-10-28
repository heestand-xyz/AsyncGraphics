//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
@preconcurrency import AVKit
import os

@available(*, deprecated, renamed: "Graphic.Camera")
typealias CameraController = Graphic.Camera

extension Graphic {
    
    public final class Camera: NSObject, Sendable {

        private struct FrameRequest: Sendable {
            let id: UUID
            let handler: @Sendable (Graphic?) -> Void
        }
        
        public enum CameraError: LocalizedError, Sendable {
            
            case captureDeviceNotSupported
            case inputCanNotBeAdded
            case outputCanNotBeAdded
            case sessionPresetCanNotBeSet
            
            public var errorDescription: String? {
                switch self {
                case .captureDeviceNotSupported:
                    return "AsyncGraphics - Camera - Capture Device Not Supported"
                case .inputCanNotBeAdded:
                    return "AsyncGraphics - Camera - Input Can Not be Added"
                case .outputCanNotBeAdded:
                    return "AsyncGraphics - Camera - Output Can Not be Added"
                case .sessionPresetCanNotBeSet:
                    return "AsyncGraphics - Camera - Session Preset Can Not be Set"
                }
            }
        }
        
        let position: AVCaptureDevice.Position
        private let device: AVCaptureDevice
#if os(iOS) && !targetEnvironment(macCatalyst)
        @MainActor
        private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?

        @available(iOS 27.0, *)
        @MainActor
        func rotationAngle(relativeTo orientation: AVCaptureVideoOrientation) -> CGFloat {
            let coordinator = rotationCoordinator
                ?? AVCaptureDevice.RotationCoordinator(device: device, previewLayer: nil)
            rotationCoordinator = coordinator
            return coordinator.videoRotationAngleRelative(toDeviceOrientation: orientation)
        }
#endif
        private let videoInput: AVCaptureDeviceInput
        private let videoOutput: AVCaptureVideoDataOutput
        private let captureSession: AVCaptureSession
#if !os(visionOS)
        private let preset: AVCaptureSession.Preset
#endif
        private let previewSized: Bool
        private let sessionQueue = DispatchQueue(
            label: "async-graphics.camera.session",
            qos: .userInitiated,
            autoreleaseFrequency: .workItem
        )
        private let frameRequest = OSAllocatedUnfairLock<FrameRequest?>(
            initialState: nil
        )
        
        @MainActor
        public var subjectAreaChange: (() -> Void)?
        
#if !os(visionOS)
        
        public var isCenterStageSupported: Bool {
            device.formats.contains { format in
                format.isCenterStageSupported
            }
        }
        
        @MainActor
        public var isCenterStageEnabled: Bool = AVCaptureDevice.isCenterStageEnabled {
            didSet {
                guard AVCaptureDevice.centerStageControlMode != .user else { return }
                AVCaptureDevice.isCenterStageEnabled = isCenterStageEnabled
            }
        }
        
        public convenience init(_ position: AVCaptureDevice.Position,
                                with deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                                quality preset: AVCaptureSession.Preset = .high,
                                external: Bool = false,
                                centerStage: Bool = true) throws {
            try self.init(
                position,
                with: deviceType,
                quality: preset,
                external: external,
                centerStage: centerStage,
                previewSized: false
            )
        }

        /// Creates a camera that can deliver screen-sized preview buffers while retaining
        /// the selected capture preset's framing and aspect ratio.
        public convenience init(_ position: AVCaptureDevice.Position,
                                with deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                                quality preset: AVCaptureSession.Preset = .high,
                                external: Bool = false,
                                centerStage: Bool = true,
                                previewSized: Bool) throws {
            
            var device: AVCaptureDevice! = .default(deviceType,
                                                    for: .video,
                                                    position: position)

            #if os(macOS)
            if external {
                let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.external],
                                                                        mediaType: .video,
                                                                        position: position)
                for iDevice in discoverySession.devices {
                    guard iDevice != device else { continue }
                    guard iDevice.hasMediaType(.video) else { continue }
                    device = iDevice
                    break
                }
            }
            #endif
            
            if device == nil {
                throw CameraError.captureDeviceNotSupported
            }
            try self.init(
                device: device,
                quality: preset,
                previewSized: previewSized
            )
            
            AVCaptureDevice.isCenterStageEnabled = centerStage
            isCenterStageEnabled = centerStage
        }
        
        public convenience init(device: AVCaptureDevice,
                                quality preset: AVCaptureSession.Preset = .high) throws {
            try self.init(
                device: device,
                quality: preset,
                previewSized: false
            )
        }

        /// Creates a camera that can deliver screen-sized preview buffers while retaining
        /// the selected capture preset's framing and aspect ratio.
        public init(device: AVCaptureDevice,
                    quality preset: AVCaptureSession.Preset = .high,
                    previewSized: Bool) throws {
            
            self.position = device.position
            self.device = device
            self.preset = preset
            self.previewSized = previewSized
            
            AVCaptureDevice.centerStageControlMode = .app
            
#if os(iOS)
            do {
                try device.lockForConfiguration()
                device.isSubjectAreaChangeMonitoringEnabled = true
                device.unlockForConfiguration()
            } catch {}
#endif
            
            captureSession = AVCaptureSession()

            videoInput = try AVCaptureDeviceInput(device: device)

            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(
                label: "async-graphics.camera.frames",
                qos: .userInitiated,
                autoreleaseFrequency: .workItem
            )
            
            super.init()

            videoOutput.setSampleBufferDelegate(self, queue: queue)
            
#if os(iOS)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(subjectAreaDidChange),
                name: .AVCaptureDeviceSubjectAreaDidChange,
                object: device
            )
#endif
        }
#else
        public init(device: AVCaptureDevice) throws {
            
            self.position = device.position
            self.device = device
            previewSized = false
            
            captureSession = AVCaptureSession()

            videoInput = try AVCaptureDeviceInput(device: device)

            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(
                label: "async-graphics.camera.frames",
                qos: .userInitiated,
                autoreleaseFrequency: .workItem
            )
            
            super.init()

            videoOutput.setSampleBufferDelegate(self, queue: queue)
        }
#endif
        
        @objc
        private func subjectAreaDidChange() {
            Task { @MainActor in
                subjectAreaChange?()
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            cancelFrameRequest()

            let captureSession = captureSession
            let videoInput = videoInput
            let videoOutput = videoOutput
            sessionQueue.async {
                Self.stop(
                    captureSession: captureSession,
                    videoInput: videoInput,
                    videoOutput: videoOutput
                )
            }
        }
        
#if !os(visionOS)
        /// Focus on a normalized focus point.
        ///
        /// Listen to focus change by setting callback of ``subjectAreaChange`` on the ``Camera``.
        ///
        /// **Apple:** This property’s CGPoint value uses a coordinate system where {0,0} is the top-left of the picture area and {1,1} is the bottom-right. This coordinate system is always relative to a landscape device orientation with the home button on the right, regardless of the actual device orientation.
        public func focus(
            at point: CGPoint,
            mode: AVCaptureDevice.FocusMode = .continuousAutoFocus
        ) {
            guard device.isFocusPointOfInterestSupported else { return }
            guard (try? device.lockForConfiguration()) != nil else { return }
            device.focusPointOfInterest = point
            device.focusMode = mode
            device.unlockForConfiguration()
        }
#endif

        /// Start Camera
        ///
        /// Starts the capture session and returns after startup finishes.
        /// Automatically called on when used with ``Graphic.camera(with:)``.
        public func start() async throws(CameraError) {
            let result: Result<Void, CameraError> = await withCheckedContinuation { continuation in
                sessionQueue.async { [self] in
                    guard !captureSession.isRunning else {
                        continuation.resume(returning: .success(()))
                        return
                    }
                    let result: Result<Void, CameraError> = configureCaptureSession()
                    if case .success = result {
                        startCaptureSession()
                    }
                    continuation.resume(returning: result)
                }
            }
            if case .failure(let error) = result {
                throw error
            }
        }
        
        /// Stop Camera
        ///
        /// Stops the capture session.
        /// In async or actor-isolated code, prefer ``stopAndWait()`` to avoid blocking.
        public func stop() {
            cancelFrameRequest()
            sessionQueue.sync { [self] in
                stopCaptureSession()
            }
        }

        func stopWithoutWaiting() {
            cancelFrameRequest()
            sessionQueue.async { [self] in
                stopCaptureSession()
            }
        }

        /// Stops the capture session and returns after the camera is released.
        ///
        /// Use this before handing the camera to another capture session or lens.
        public func stopAndWait() async {
            cancelFrameRequest()
            await withCheckedContinuation { continuation in
                sessionQueue.async { [self] in
                    stopCaptureSession()
                    continuation.resume()
                }
            }
        }

        func nextGraphic() async -> Graphic? {
            let id = UUID()
            return await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    let request = FrameRequest(id: id) { graphic in
                        continuation.resume(returning: graphic)
                    }
                    let previousRequest = frameRequest.withLock { pendingRequest in
                        let previousRequest = pendingRequest
                        pendingRequest = request
                        return previousRequest
                    }
                    previousRequest?.handler(nil)
                    if Task.isCancelled {
                        cancelFrameRequest(id: id)
                    }
                }
            } onCancel: {
                self.cancelFrameRequest(id: id)
            }
        }

        private func startCaptureSession() {
            guard !captureSession.isRunning else { return }
            captureSession.startRunning()
        }

        private func configureCaptureSession() -> Result<Void, CameraError> {
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }

            if !captureSession.inputs.contains(where: { $0 === videoInput }) {
                guard captureSession.canAddInput(videoInput) else {
                    return .failure(.inputCanNotBeAdded)
                }
                captureSession.addInput(videoInput)
            }

#if !os(visionOS)
            guard captureSession.canSetSessionPreset(preset) else {
                return .failure(.sessionPresetCanNotBeSet)
            }
            captureSession.sessionPreset = preset
#endif

            var videoSettings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
#if os(macOS)
            if let dimensions: CMVideoDimensions = preset.fixedVideoDimensions {
                videoSettings[kCVPixelBufferWidthKey as String] = Int(dimensions.width)
                videoSettings[kCVPixelBufferHeightKey as String] = Int(dimensions.height)
            }
#endif
            videoOutput.videoSettings = videoSettings
#if os(iOS) || os(tvOS)
            if previewSized {
                videoOutput.automaticallyConfiguresOutputBufferDimensions = false
                videoOutput.deliversPreviewSizedOutputBuffers = true
            }
#endif

            if !captureSession.outputs.contains(where: { $0 === videoOutput }) {
                guard captureSession.canAddOutput(videoOutput) else {
                    return .failure(.outputCanNotBeAdded)
                }
                captureSession.addOutput(videoOutput)
            }
#if os(iOS) && !targetEnvironment(macCatalyst)
            if #available(iOS 27.0, *), let connection = videoOutput.connection(with: .video) {
                // Rotation happens once on the Graphic, after receiving the buffer.
                connection.videoRotationAngle = 0
                if connection.isVideoMirroringSupported {
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = false
                }
            }
#endif
            return .success(())
        }

        private func stopCaptureSession() {
            Self.stop(
                captureSession: captureSession,
                videoInput: videoInput,
                videoOutput: videoOutput
            )
        }

        private static func stop(
            captureSession: AVCaptureSession,
            videoInput: AVCaptureDeviceInput,
            videoOutput: AVCaptureVideoDataOutput
        ) {
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
            guard captureSession.inputs.contains(where: { $0 === videoInput })
                    || captureSession.outputs.contains(where: { $0 === videoOutput })
            else { return }
            captureSession.beginConfiguration()
            if captureSession.outputs.contains(where: { $0 === videoOutput }) {
                captureSession.removeOutput(videoOutput)
            }
            if captureSession.inputs.contains(where: { $0 === videoInput }) {
                captureSession.removeInput(videoInput)
            }
            captureSession.commitConfiguration()
        }

        private func cancelFrameRequest(id: UUID? = nil) {
            let handler = frameRequest.withLock { pendingRequest -> (@Sendable (Graphic?) -> Void)? in
                guard id == nil || pendingRequest?.id == id else { return nil }
                let handler = pendingRequest?.handler
                pendingRequest = nil
                return handler
            }
            handler?(nil)
        }
    }
}

// MARK: - Preset

#if os(macOS)
private extension AVCaptureSession.Preset {

    var fixedVideoDimensions: CMVideoDimensions? {
        if self == .vga640x480 {
            return CMVideoDimensions(width: 640, height: 480)
        }
        if self == .hd1280x720 {
            return CMVideoDimensions(width: 1_280, height: 720)
        }
        if self == .hd1920x1080 {
            return CMVideoDimensions(width: 1_920, height: 1_080)
        }
        if self == .hd4K3840x2160 {
            return CMVideoDimensions(width: 3_840, height: 2_160)
        }
        return nil
    }
}
#endif

// MARK: - Sample Buffer Delegate

extension Graphic.Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let request = frameRequest.withLock({ $0 }) else { return }
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let texture: MTLTexture = try? pixelBuffer.texture(),
              let graphic: Graphic = try? .texture(texture)
        else { return }

        let handler = frameRequest.withLock { pendingRequest -> (@Sendable (Graphic?) -> Void)? in
            guard pendingRequest?.id == request.id else { return nil }
            pendingRequest = nil
            return request.handler
        }
        handler?(graphic)
    }
}
