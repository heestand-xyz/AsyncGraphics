//
//  Created by Anton Heestand on 2022-08-21.
//

import CoreGraphics
import AVFoundation

final class GraphicVideoController: NSObject, GraphicVideoPlayerDelegate, Sendable {
    
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
    
    @MainActor
    private var timer: Timer?
    
    @MainActor
    private var videoOutput: AVPlayerItemVideoOutput?
    
    @MainActor
    var graphicsHandler: ((Graphic) -> ())? {
        didSet {
            forceGoTo(time: videoPlayer.time)
        }
    }

    // MARK: Life Cycle
    
    init(videoPlayer: GraphicVideoPlayer) {
        
        self.videoPlayer = videoPlayer
        
        super.init()

        Task { @MainActor in
            let attributes = [
                kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)
            ]
            let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
            self.videoOutput = videoOutput
            videoPlayer.item.add(videoOutput)
            videoPlayer.delegate = self
        }      
    }
    
    @MainActor
    func cancel() {
        graphicsHandler = nil
        Task { @MainActor in
            videoPlayer.pause()
        }
        timer?.invalidate()
    }
    
    // MARK: Read Buffer
    
    @MainActor
    func play(time: CMTime) {
        do {
            try goTo(time: time)
        } catch {
            print("AsyncGraphics - Video Controller - Render (at second \(time.seconds)) Failed:", error)
        }
    }
    
    @MainActor
    private func goTo(time: CMTime) throws {
        
        guard videoOutput?.hasNewPixelBuffer(forItemTime: time) == true else {
            throw VideoControllerError.hasNoNewPixelBuffer
        }
        guard let pixelBuffer = videoOutput?.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {
            throw VideoControllerError.copyPixelBufferFailed
        }
        
        let texture: MTLTexture = try pixelBuffer.texture()
        let graphic: Graphic = try .texture(texture)

        graphicsHandler?(graphic)
    }
    
    @MainActor
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
