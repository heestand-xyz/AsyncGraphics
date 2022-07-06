//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
import AVKit

class CameraController: NSObject {
    
    enum CameraError: LocalizedError {
        
        case cameraCaptureDeviceNotSupported
        case cameraInputCanNotBeAdded
        case cameraOutputCanNotBeAdded
        case cameraSessionPresetCanNotBeSet
        
        var errorDescription: String? {
            switch self {
            case .cameraCaptureDeviceNotSupported:
                return "AsyncGraphics - Camera - Capture Device Not Supported"
            case .cameraInputCanNotBeAdded:
                return "AsyncGraphics - Camera - Input Can Not be Added"
            case .cameraOutputCanNotBeAdded:
                return "AsyncGraphics - Camera - Output Can Not be Added"
            case .cameraSessionPresetCanNotBeSet:
                return "AsyncGraphics - Camera - Session Preset Can Not be Added"
            }
        }
    }
    
    var cameraFrameHandler: ((Graphic) -> ())?
    
    let captureSession: AVCaptureSession
    let videoOutput: AVCaptureVideoDataOutput
    
    var index: Int = 0
    
    init(deviceType: AVCaptureDevice.DeviceType,
         position: AVCaptureDevice.Position,
         preset: AVCaptureSession.Preset) throws {
        
        print("AsyncGraphics - CameraController - Init")
        
        guard let device = AVCaptureDevice.default(deviceType, for: .video, position: position) else {
            throw CameraError.cameraCaptureDeviceNotSupported
        }

        captureSession = AVCaptureSession()
        
        guard captureSession.canSetSessionPreset(preset) else {
            throw CameraError.cameraSessionPresetCanNotBeSet
        }
        captureSession.sessionPreset = preset
        
        let input = try AVCaptureDeviceInput(device: device)
        guard captureSession.canAddInput(input) else {
            throw CameraError.cameraInputCanNotBeAdded
        }
        captureSession.addInput(input)
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let queue = DispatchQueue(label: "async-graphics.camera")
        
        guard captureSession.canAddOutput(videoOutput) else {
            throw CameraError.cameraOutputCanNotBeAdded
        }
        captureSession.addOutput(videoOutput)

        super.init()
        
        videoOutput.setSampleBufferDelegate(self, queue: queue)

        captureSession.startRunning()
    }
    
    deinit {
        print("AsyncGraphics - CameraController - Deinit")
        captureSession.stopRunning()
    }
    
    func cancel() {
        captureSession.stopRunning()
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let texture: MTLTexture = try? pixelBuffer.texture(),
              let graphic: Graphic = try? .texture(texture)
        else { return }
    
        cameraFrameHandler?(graphic)
    }
}
