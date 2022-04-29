//
//  Created by Anton Heestand on 2022-04-06.
//

import Foundation
import VideoFrames
import TextureMap

extension Graphic {
    
    /// Import a video from a URL
    public static func videoFrames(url: URL) async throws -> [Graphic] {
        
        let images: [TMImage] = try await convertVideoToFrames(from: url)
                
        let graphics: [Graphic] = try await withThrowingTaskGroup(of: (Int, Graphic).self) { group in
        
            for (index, image) in images.enumerated() {
                group.addTask {
                    let graphic: Graphic = try await .image(image)
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
}


extension Array where Element == Graphic {
    
    /// Import a video from a URL
    public static func videoFrames(url: URL) async throws -> [Graphic] {
        
        try await Graphic.videoFrames(url: url)
    }
}
