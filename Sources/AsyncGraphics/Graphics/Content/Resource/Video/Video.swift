//
//  Created by Anton Heestand on 2022-08-21.
//

import Foundation
import VideoFrames

extension Graphic {
    
    /// Async stream of a video
    public static func playVideo(url: URL, loop: Bool = false, volume: Double = 1.0) -> AsyncStream<Graphic> {
        
        var options = GraphicVideoPlayer.Options()
        options.loop = loop
        options.volume = volume
        let videoPlayer = GraphicVideoPlayer(url: url, options: options)
        
        return playVideo(with: videoPlayer)
    }
    
    /// Async stream of a video
    public static func playVideo(with videoPlayer: GraphicVideoPlayer) -> AsyncStream<Graphic> {
        
        let videoController = GraphicVideoController(videoPlayer: videoPlayer)
        
        return AsyncStream<Graphic> { stream in
            
            stream.onTermination = { @Sendable _ in
                videoController.cancel()
            }
            
            videoController.graphicsHandler = { graphic in
                stream.yield(graphic)
            }
        }
    }
}

extension Graphic {
    
    /// Async _direct_ stream of a video
    ///
    /// This stream will continue as soon as the async block is done
    public static func processVideo(url: URL) throws -> AsyncThrowingStream<_Image, Error> {
        try convertVideoToFrames(from: url)
    }
}
