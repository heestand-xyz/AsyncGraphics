//
//  Created by Anton Heestand on 2022-04-06.
//

import Foundation
import VideoFrames
import TextureMap

extension Graphic {
    
    /// Export a video to Data
    public static func videoData(with graphics: [Graphic],
                                 fps: Int = 30,
                                 kbps: Int = 1_000, format: VideoFormat = .mov) async throws -> Data {
        
        let url: URL = try await videoURL(with: graphics,
                                          fps: fps,
                                          kbps: kbps,
                                          format: format)
        
        let data = try Data(contentsOf: url)
        
        return data
    }
    
    /// Export a video to a URL
    public static func videoURL(with graphics: [Graphic],
                                fps: Int = 30,
                                kbps: Int = 1_000,
                                format: VideoFormat = .mov) async throws -> URL {
        
        let images: [TMImage] = try await withThrowingTaskGroup(of: (Int, TMImage).self) { group in
            
            for (index, graphic) in graphics.enumerated() {
                group.addTask {
                    let image: TMImage = try await graphic.image
                    return (index, image)
                }
            }
            
            var images: [(Int, TMImage)] = []
            
            for try await (index, image) in group {
                images.append((index, image))
            }
            
            return images
                .sorted(by: { leadingPack, trailingPack in
                    leadingPack.0 < trailingPack.0
                })
                .map(\.1)
        }
        
        let id = UUID().uuidString.split(separator: "-").first!
        let name: String = "AsyncGraphics_\(id).\(format.rawValue)"
        
        let folderURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("AsyncGraphics")
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        let url: URL = folderURL.appendingPathComponent("\(name)")
        
        try await convertFramesToVideo(images: images, fps: fps, kbps: kbps, as: format, url: url)
        
        return url
    }
}

extension Array where Element == Graphic {
    
    /// Export a video to Data
    public func videoData(fps: Int = 30, kbps: Int = 1_000, format: VideoFormat = .mov) async throws -> Data {
        
        try await Graphic.videoData(with: self, fps: fps, kbps: kbps, format: format)
    }
    
    /// Export a video to a URL
    public func videoURL(fps: Int = 30, kbps: Int = 1_000, format: VideoFormat = .mov) async throws -> URL {
        
        try await Graphic.videoURL(with: self, fps: fps, kbps: kbps, format: format)
    }
}
