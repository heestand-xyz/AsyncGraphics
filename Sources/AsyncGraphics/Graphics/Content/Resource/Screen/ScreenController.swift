//
//  Created by Anton Heestand on 2022-04-27.
//

import Metal
import AVKit

class ScreenController: NSObject {
    
    enum ScreenError: LocalizedError {
        
        case indexOutOfBounds
        case inputCanNotBeCreated
        case inputCanNotBeAdded
        case outputCanNotBeAdded
        case sessionPresetCanNotBeSet
        
        var errorDescription: String? {
            switch self {
            case .indexOutOfBounds:
                return "AsyncGraphics - Screen - Index Out of Bounds"
            case .inputCanNotBeCreated:
                return "AsyncGraphics - Screen - Input Can Not be Created"
            case .inputCanNotBeAdded:
                return "AsyncGraphics - Screen - Input Can Not be Added"
            case .outputCanNotBeAdded:
                return "AsyncGraphics - Screen - Output Can Not be Added"
            case .sessionPresetCanNotBeSet:
                return "AsyncGraphics - Screen - Session Preset Can Not be Added"
            }
        }
    }
    
    var cameraFrameHandler: ((Graphic) -> ())?
        
    private let captureSession: AVCaptureSession
    private let videoOutput: AVCaptureVideoDataOutput
    
    init(index: Int) throws {
        
        guard NSScreen.screens.indices.contains(index) else {
            throw ScreenError.indexOutOfBounds
        }
        let screen = NSScreen.screens[index]
        
        let screenNumberKey = NSDeviceDescriptionKey(rawValue: "NSScreenNumber")
        let id = screen.deviceDescription[screenNumberKey] as! CGDirectDisplayID
        
        guard let input = AVCaptureScreenInput(displayID: id) else {
            throw ScreenError.inputCanNotBeCreated
        }
        
        captureSession = AVCaptureSession()
        
        guard captureSession.canAddInput(input) else {
            throw ScreenError.inputCanNotBeAdded
        }
        captureSession.addInput(input)
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let queue = DispatchQueue(label: "async-graphics.screen")
        
        guard captureSession.canAddOutput(videoOutput) else {
            throw ScreenError.outputCanNotBeAdded
        }
        captureSession.addOutput(videoOutput)

        super.init()
        
        videoOutput.setSampleBufferDelegate(self, queue: queue)

        captureSession.startRunning()
    }
    
    deinit {
        captureSession.stopRunning()
    }
    
    func cancel() {
        captureSession.stopRunning()
    }
}

extension ScreenController: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let texture: MTLTexture = try? pixelBuffer.texture(),
              let graphic: Graphic = try? .texture(texture)
        else { return }
    
        cameraFrameHandler?(graphic)
    }
}
