//
//  Created by Anton Heestand on 2022-08-21.
//

#if !os(xrOS)

import CoreGraphics
import AVFoundation

class GraphicVideoController: NSObject, GraphicVideoPlayerDelegate {
    
    enum VideoControllerError: LocalizedError {
        case hasNoNewPixelBuffer
        case copyPixelBufferFailed
        var errorDescription: String? {
            switch self {
            case .hasNoNewPixelBuffer:
                return "AsyncGraphics - Graphic - VideoController - Has No New Pixel Buffer"
            case .copyPixelBufferFailed:
                return "AsyncGraphics - Graphic - VideoController - Copy Pixel Buffer Failed"
            }
        }
    }
    
    private let videoPlayer: GraphicVideoPlayer
    
    private var timer: Timer?
    
    private let videoOutput: AVPlayerItemVideoOutput
        
    var graphicsHandler: ((Graphic) -> ())? {
        didSet {
            forceGoTo(time: videoPlayer.time)
        }
    }

    // MARK: Life Cycle
    
    init(videoPlayer: GraphicVideoPlayer) {
        
        self.videoPlayer = videoPlayer
        
        let attributes = [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)
        ]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
        
        videoPlayer.item.add(videoOutput)
                    
        super.init()
        
        videoPlayer.delegate = self
    }
    
    func cancel() {
        graphicsHandler = nil
        videoPlayer.pause()
        timer?.invalidate()
    }
    
    // MARK: Read Buffer
    
    func play(time: CMTime) {
        do {
            try goTo(time: time)
        } catch {
            print("AsyncGraphics - Video Controller - Render (at second \(time.seconds)) Failed:", error)
        }
    }
    
    private func goTo(time: CMTime) throws {
        
        guard videoOutput.hasNewPixelBuffer(forItemTime: time) else {
            throw VideoControllerError.hasNoNewPixelBuffer
        }
        guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {
            throw VideoControllerError.copyPixelBufferFailed
        }
        
        let texture: MTLTexture = try pixelBuffer.texture()
        let graphic: Graphic = try .texture(texture)

        graphicsHandler?(graphic)
    }
    
    private func forceGoTo(time: CMTime, attemptCount: Int = 10, attemptDelay: Double = 0.1) {
        do {
            try goTo(time: time)
        } catch {
            guard attemptCount > 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + attemptDelay) {
                self.forceGoTo(time: time, attemptCount: attemptCount - 1, attemptDelay: attemptDelay)
            }
        }
    }
}

#endif
