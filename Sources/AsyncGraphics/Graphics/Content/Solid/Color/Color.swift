//
//  Created by Anton Heestand on 2022-04-04.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct ColorUniforms: Uniforms {
        let premultiply: Bool
        let color: ColorUniform
    }
    
    public static func color(_ color: PixelColor,
                             resolution: CGSize,
                             options: ContentOptions = []) async throws -> Graphic {
                
        try await Renderer.render(
            name: "Color",
            shader: .name("color"),
            uniforms: ColorUniforms(
                premultiply: options.premultiply,
                color: color.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
