//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
@preconcurrency import AVKit

@available(*, deprecated, renamed: "Graphic.Camera")
typealias CameraController = Graphic.Camera

extension Graphic {
    
    public final class Camera: NSObject, Sendable {
        
        enum CameraError: LocalizedError {
            
            case captureDeviceNotSupported
            case inputCanNotBeAdded
            case outputCanNotBeAdded
            case sessionPresetCanNotBeSet
            
            var errorDescription: String? {
                switch self {
                case .captureDeviceNotSupported:
                    return "AsyncGraphics - Camera - Capture Device Not Supported"
                case .inputCanNotBeAdded:
                    return "AsyncGraphics - Camera - Input Can Not be Added"
                case .outputCanNotBeAdded:
                    return "AsyncGraphics - Camera - Output Can Not be Added"
                case .sessionPresetCanNotBeSet:
                    return "AsyncGraphics - Camera - Session Preset Can Not be Added"
                }
            }
        }
        
        @MainActor
        var graphicsHandler: ((Graphic) -> ())?
        
        let position: AVCaptureDevice.Position
        private let device: AVCaptureDevice
        private let videoInput: AVCaptureDeviceInput
        private let videoOutput: AVCaptureVideoDataOutput
        private let captureSession: AVCaptureSession
        
        @MainActor
        public var subjectAreaChange: (() -> Void)?
        
#if !os(visionOS)
        public convenience init(_ position: AVCaptureDevice.Position,
                                with deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
                                quality preset: AVCaptureSession.Preset = .high,
                                external: Bool = false,
                                centerStage: Bool = true) throws {
            
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
            
            AVCaptureDevice.centerStageControlMode = .app
            AVCaptureDevice.isCenterStageEnabled = centerStage
            
            try self.init(device: device, quality: preset)
        }
        
        public init(device: AVCaptureDevice,
                    quality preset: AVCaptureSession.Preset = .high) throws {
            
            self.position = device.position
            self.device = device
            
#if os(iOS)
            do {
                try device.lockForConfiguration()
                device.isSubjectAreaChangeMonitoringEnabled = true
                device.unlockForConfiguration()
            } catch {}
#endif
            
            captureSession = AVCaptureSession()
            
            guard captureSession.canSetSessionPreset(preset) else {
                throw CameraError.sessionPresetCanNotBeSet
            }
            captureSession.sessionPreset = preset
            
            videoInput = try AVCaptureDeviceInput(device: device)
            guard captureSession.canAddInput(videoInput) else {
                throw CameraError.inputCanNotBeAdded
            }
            
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            let queue = DispatchQueue(label: "async-graphics.camera")
            
            guard captureSession.canAddOutput(videoOutput) else {
                throw CameraError.outputCanNotBeAdded
            }
            
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
            
            captureSession = AVCaptureSession()
            
            videoInput = try AVCaptureDeviceInput(device: device)
            guard captureSession.canAddInput(videoInput) else {
                throw CameraError.inputCanNotBeAdded
            }
            
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            let queue = DispatchQueue(label: "async-graphics.camera")
            
            guard captureSession.canAddOutput(videoOutput) else {
                throw CameraError.outputCanNotBeAdded
            }
            
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
            stop()
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
        /// Starts the capture session.
        /// Automatically called on when used with ``Graphic.camera(with:)``.
        public func start() {
            if captureSession.isRunning { return }
            captureSession.addInput(videoInput)
            captureSession.addOutput(videoOutput)
            Task {
                captureSession.startRunning()
            }
        }
        
        /// Stop Camera
        ///
        /// Stops the capture session.
        public func stop() {
            guard captureSession.isRunning else { return }
            captureSession.removeInput(videoInput)
            captureSession.removeOutput(videoOutput)
            captureSession.stopRunning()
        }
    }
}

extension Graphic.Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let texture: MTLTexture = try? pixelBuffer.texture(),
              let graphic: Graphic = try? .texture(texture)
        else { return }
    
        Task { @MainActor in
            graphicsHandler?(graphic)
        }
    }
}
