//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics

extension Graphic {
    
    func downSample() async throws -> Graphic {
        
        try await Renderer.render(
            name: "Down Sample",
            shader: .name("downSample"),
            graphics: [self],
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}
