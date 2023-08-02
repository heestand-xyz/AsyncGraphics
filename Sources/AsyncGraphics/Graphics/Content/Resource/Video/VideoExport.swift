//
//  Created by Anton Heestand on 2022-04-06.
//

import Foundation
import VideoFrames
import TextureMap

extension Graphic {
    
    /// Export a video to Data
    public static func exportVideoToData(with graphics: [Graphic],
                                         fps: Double = 30.0,
                                         kbps: Int = 1_000,
                                         format: VideoFormat = .mov,
                                         codec: VideoCodec = .h264) async throws -> Data {
        
        let url: URL = try await exportVideoToURL(with: graphics,
                                                  fps: fps,
                                                  kbps: kbps,
                                                  format: format,
                                                  codec: codec)
        
        let data = try Data(contentsOf: url)
        
        try FileManager.default.removeItem(at: url)
        
        return data
    }
    
    /// Export a video to a URL
    public static func exportVideoToURL(with graphics: [Graphic],
                                        fps: Double = 30.0,
                                        kbps: Int = 1_000,
                                        format: VideoFormat = .mov,
                                        codec: VideoCodec = .h264) async throws -> URL {
        
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
        
        try await convertFramesToVideo(
            images: images,
            fps: fps,
            kbps: kbps,
            format: format,
            codec: codec,
            url: url
        )
        
        return url
    }
}

extension Array where Element == Graphic {
    
    /// Export a video to Data
    public func exportVideoToData(fps: Double = 30.0,
                                  kbps: Int = 1_000,
                                  format: VideoFormat = .mov,
                                  codec: VideoCodec = .h264) async throws -> Data {
        
        try await Graphic.exportVideoToData(with: self,
                                            fps: fps,
                                            kbps: kbps,
                                            format: format,
                                            codec: codec)
    }
    
    /// Export a video to a URL
    public func exportVideoToURL(fps: Double = 30.0,
                                 kbps: Int = 1_000,
                                 format: VideoFormat = .mov,
                                 codec: VideoCodec = .h264) async throws -> URL {
        
        try await Graphic.exportVideoToURL(with: self,
                                           fps: fps,
                                           kbps: kbps,
                                           format: format,
                                           codec: codec)
    }
}
