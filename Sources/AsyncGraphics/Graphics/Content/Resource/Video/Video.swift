//
//  Created by Anton Heestand on 2022-08-21.
//

import Foundation

extension Graphic {
    
    /// Async live stream of a video
    public static func playVideo(url: URL, loop: Bool = false, volume: Double = 1.0) throws -> AsyncStream<Graphic> {
        
        var options = VideoPlayer.Options()
        options.loop = loop
        options.volume = volume
        let videoPlayer = try VideoPlayer(url: url, options: options)
        
        return try playVideo(with: videoPlayer)
    }
    
    /// Async live stream of a videos
    public static func playVideo(with videoPlayer: VideoPlayer) throws -> AsyncStream<Graphic> {
        
        let videoController = VideoController(videoPlayer: videoPlayer)
        
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
