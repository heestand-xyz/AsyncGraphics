//
//  Created by Anton Heestand on 2022-04-06.
//

import Foundation
import VideoFrames
import TextureMap

extension Graphic {
    
    public struct VideoDetails {
        public let resolution: CGSize
        public let frameCount: Int
        /// In seconds
        public let duration: Double
        /// Frames per second
        public let fps: Double
    }
    
    public static func videoDetails(url: URL) async throws -> VideoDetails {
        let info = try await VideoInfo(url: url)
        return VideoDetails(resolution: info.size,
                            frameCount: info.frameCount,
                            duration: info.duration,
                            fps: info.fps)
    }
    
    public struct ImportVideoFrameProgress {
        public let index: Int
        public let fraction: CGFloat
    }
    
    /// Import a video from a URL
    public static func importVideo(url: URL, progress: ((ImportVideoFrameProgress) -> ())? = nil) async throws -> [Graphic] {
        
        var frameCount: Int?
        let images: [TMImage] = try await convertVideoToFrames(from: url) { count in
            frameCount = count
        } progress: { index in
            guard let frameCount
            else { return }
            let fraction = CGFloat(index) / CGFloat(frameCount)
            progress?(ImportVideoFrameProgress(index: index, fraction: fraction))
        }
                
        let graphics: [Graphic] = try await withThrowingTaskGroup(of: (Int, Graphic).self) { group in
        
            for (index, image) in images.enumerated() {
                let sendableImage: SendableImage = image.send()
                group.addTask {
                    let graphic: Graphic = try await .image(sendableImage.receive())
                    return (index, graphic)
                }
            }
            
            var graphics: [(Int, Graphic)] = []
            
            for try await (index, graphic) in group {
                graphics.append((index, graphic))
            }
            
            return graphics
                .sorted(by: { leadingPack, trailingPack in
                    leadingPack.0 < trailingPack.0
                })
                .map(\.1)
        }
        
        return graphics
    }
    
    /// Import a video from a URL via a stream
    public static func importVideoStream(url: URL) -> AsyncThrowingStream<Graphic, Error> {
        AsyncThrowingStream { stream in
            Task {
                do {
                    for try await image in try await convertVideoToFrames(from: url) {
                        let graphic: Graphic = try await .image(image)
                        stream.yield(graphic)
                    }
                } catch {
                    stream.finish(throwing: error)
                }
                stream.finish()
            }
        }
    }
    
    /// Import Video Frame
    ///
    /// If info is `nil` (default), frame count, frame rate and resolution will be automatically calculate based on the video at the url.
    ///
    /// Pass info to override frame count, frame rate and resolution.
    ///
    /// `Import VideoFrames` to access `VideoInfo`
    public static func importVideoFrame(at frameIndex: Int, url: URL, info: VideoInfo? = nil) async throws -> Graphic {
        let image: TMImage = try await videoFrame(at: frameIndex, from: url, info: info)
        return try await .image(image)
    }
}


extension Array where Element == Graphic {
    
    /// Import a video from a URL
    public static func importVideo(url: URL, progress: ((Graphic.ImportVideoFrameProgress) -> ())? = nil) async throws -> [Graphic] {
        
        try await Graphic.importVideo(url: url, progress: progress)
    }
}
