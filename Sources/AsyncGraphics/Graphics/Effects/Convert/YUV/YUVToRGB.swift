//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics

extension Graphic {
    
    /// YUV (420v) to RGB
    ///
    /// `y` in red, `uv` in red and green channels.
    ///
    /// Resolution, color space and bits is derived from the `y` graphic.
    public static func rgb(y: Graphic, uv: Graphic) async throws -> Graphic {
        
        try await Renderer.render(
            name: "YUVToRGB",
            shader: .name("yuvToRGB"),
            graphics: [y, uv],
            metadata: Renderer.Metadata(
                resolution: y.resolution,
                colorSpace: y.colorSpace,
                bits: y.bits
            )
        )
    }
}
