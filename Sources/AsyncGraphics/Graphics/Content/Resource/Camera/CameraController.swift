//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
import AVKit

class CameraController: NSObject {
    
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
    
    private let captureSession: AVCaptureSession
    private let videoInput: AVCaptureDeviceInput
    private let videoOutput: AVCaptureVideoDataOutput
   
    init(deviceType: AVCaptureDevice.DeviceType,
         position: AVCaptureDevice.Position,
         preset: AVCaptureSession.Preset) throws {
        
        guard let device = AVCaptureDevice.default(deviceType, for: .video, position: position) else {
            throw CameraError.captureDeviceNotSupported
        }

        captureSession = AVCaptureSession()
        
        guard captureSession.canSetSessionPreset(preset) else {
            throw CameraError.sessionPresetCanNotBeSet
        }
        captureSession.sessionPreset = preset
        
        videoInput = try AVCaptureDeviceInput(device: device)
        guard captureSession.canAddInput(videoInput) else {
            throw CameraError.inputCanNotBeAdded
        }
        captureSession.addInput(videoInput)
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let queue = DispatchQueue(label: "async-graphics.camera")
        
        guard captureSession.canAddOutput(videoOutput) else {
            throw CameraError.outputCanNotBeAdded
        }
        captureSession.addOutput(videoOutput)

        super.init()
        
        DispatchQueue.global().async { [weak self] in
            self?.videoOutput.setSampleBufferDelegate(self, queue: queue)
            self?.captureSession.startRunning()
        }
    }
    
    deinit {
        cancel()
    }
    
    func cancel() {
        captureSession.stopRunning()
        captureSession.removeInput(videoInput)
        captureSession.removeOutput(videoOutput)
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let texture: MTLTexture = try? pixelBuffer.texture(),
              let graphic: Graphic = try? .texture(texture)
        else { return }
    
        graphicsHandler?(graphic)
    }
}
