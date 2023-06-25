//
//  Created by Anton Heestand on 2022-08-21.
//

#if !os(xrOS)

import Foundation
import VideoFrames

extension Graphic {
    
    /// Async stream of a video
    public static func playVideo(url: URL, loop: Bool = false, volume: Double = 1.0) async throws -> AsyncStream<Graphic> {
        
        var options = GraphicVideoPlayer.Options()
        options.loop = loop
        options.volume = volume
        let videoPlayer = try await GraphicVideoPlayer(url: url, options: options)
        
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
    public static func processVideo(url: URL) async throws -> AsyncThrowingStream<Graphic, Error> {
//        let videoPlayer = GraphicVideoPlayer(url: url)
//        let info = VideoInfo(duration: videoPlayer.info.duration,
//                             fps: videoPlayer.info.frameRate,
//                             size: videoPlayer.info.resolution)
        let frames: AsyncThrowingStream<_Image, Error> = try await convertVideoToFrames(from: url)
        return AsyncThrowingStream<Graphic, Error> { stream in
            Task {
                do {
                    for try await image in frames {
                        let graphic: Graphic = try await .image(image)
                        stream.yield(graphic)
                    }
                    stream.finish()
                } catch {
                    stream.finish(throwing: error)
                }
            }
        }
    }
}

#endif
