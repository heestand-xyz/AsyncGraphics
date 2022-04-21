//
//  Created by Anton Heestand on 2022-04-04.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct ColorUniforms {
        let color: ColorUniform
    }
    
    public static func color(_ color: PixelColor,
                             at graphicSize: CGSize,
                             options: Options = Options()) async throws -> Graphic {
                
        try await Renderer.render(
            name: "Color",
            shader: .name("color"),
            uniforms: ColorUniforms(color: color.uniform),
            metadata: Renderer.Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: options.bits
            )
        )
    }
}
