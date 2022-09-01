//
//  Created by Anton Heestand on 2022-08-21.
//

import Foundation

extension Graphic {
    
    /// Async live stream of a video
    public static func playVideo(url: URL, loop: Bool = false, volume: CGFloat = 1.0) -> AsyncStream<Graphic> {
        
        let videoController = VideoController(url: url, loop: loop, volume: Float(volume))
        
        return AsyncStream<Graphic> { stream in
            
            stream.onTermination = { @Sendable _ in
                videoController.cancel()
            }
                            
            videoController.graphicsHandler = { graphic in
                stream.yield(graphic)
            }
            
            videoController.endedHandler = {
                stream.finish()
            }
        }
    }
}
