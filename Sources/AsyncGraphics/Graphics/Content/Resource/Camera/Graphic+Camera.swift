//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
import AVKit

@available(*, deprecated, renamed: "Graphic.Camera")
typealias CameraController = Graphic.Camera

extension Graphic {
    
    public class Camera: NSObject {
        
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
        
        var graphicsHandler: ((Graphic) -> ())?
        
        let position: AVCaptureDevice.Position
        private let device: AVCaptureDevice
        private let videoInput: AVCaptureDeviceInput
        private let videoOutput: AVCaptureVideoDataOutput
        private let captureSession: AVCaptureSession
        
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
                let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown],
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
            
            if #available(macOS 12.3, *) {
                AVCaptureDevice.centerStageControlMode = .app
                AVCaptureDevice.isCenterStageEnabled = centerStage
            }
            
            try self.init(device: device, quality: preset)
        }
        
        public init(device: AVCaptureDevice,
                    quality preset: AVCaptureSession.Preset = .high) throws {
            
            self.position = device.position
            self.device = device
            
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
        
        deinit {
            stop()
        }
        
#if !os(visionOS)
        /// Relative focus point
        ///
        /// **Apple:** This property’s CGPoint value uses a coordinate system where {0,0} is the top-left of the picture area and {1,1} is the bottom-right. This coordinate system is always relative to a landscape device orientation with the home button on the right, regardless of the actual device orientation.
        public func focus(at point: CGPoint, mode: AVCaptureDevice.FocusMode = .continuousAutoFocus) {
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
            DispatchQueue.global().async { [weak self] in
                self?.captureSession.startRunning()
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
    
        graphicsHandler?(graphic)
    }
}
