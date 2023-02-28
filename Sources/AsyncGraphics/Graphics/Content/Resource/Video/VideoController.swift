//
//  Created by Anton Heestand on 2022-08-21.
//

import CoreGraphics
import AVFoundation

extension Graphic {

    class VideoController: NSObject, GraphicVideoPlayerDelegate {
        
        private let videoPlayer: VideoPlayer
        
        private var timer: Timer?
        
        private let videoOutput: AVPlayerItemVideoOutput
            
        var graphicsHandler: ((Graphic) -> ())?
        var endedHandler: (() -> ())?

        // MARK: Life Cycle
        
        init(videoPlayer: VideoPlayer) {
            
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
            
            guard videoOutput.hasNewPixelBuffer(forItemTime: time),
                  let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil)
            else { return }
            
            guard let texture: MTLTexture = try? pixelBuffer.texture(),
                  let graphic: Graphic = try? .texture(texture)
            else { return }

            graphicsHandler?(graphic)
        }
    }
}
