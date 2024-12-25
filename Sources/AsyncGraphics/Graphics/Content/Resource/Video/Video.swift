//
//  Created by Anton Heestand on 2022-08-21.
//

import Foundation
import VideoFrames

extension Graphic {
    
    /// Async stream of a video
    public static func playVideo(url: URL, loop: Bool = false, volume: Double = 1.0) async throws -> AsyncStream<Graphic> {
        
        var options = GraphicVideoPlayer.Options()
        options.loop = loop
        options.volume = volume
        let videoPlayer = await GraphicVideoPlayer(url: url, options: options)
        
        return playVideo(with: videoPlayer)
    }
    
    /// Async stream of a video
    public static func playVideo(with videoPlayer: GraphicVideoPlayer) -> AsyncStream<Graphic> {
        
        let videoController = GraphicVideoController(videoPlayer: videoPlayer)
        
        return AsyncStream<Graphic> { stream in
            
            stream.onTermination = { @Sendable _ in
                Task { @MainActor in
                    videoController.cancel()
                }
            }
            
            Task { @MainActor in
                videoController.graphicsHandler = { graphic in
                    stream.yield(graphic)
                }
            }
        }
    }
}

extension Graphic {
    
    /// Async stream of a video.
    ///
    /// This stream will finish as soon as all the frames have been processed.
    ///
    /// The steam does not account for the video frame rate.
    public static func processVideo(url: URL) -> AsyncThrowingStream<Graphic, Error> {
        return AsyncThrowingStream<Graphic, Error> { stream in
            Task {
                do {
                    for try await image in try await convertVideoToFrames(from: url) {
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
