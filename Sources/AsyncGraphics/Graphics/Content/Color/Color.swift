//
//  Created by Anton Heestand on 2022-04-04.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {
    
    private struct ColorUniforms {
        let color: ColorUniform
    }
    
    static func color(_ color: PixelColor, size: CGSize) async throws -> Graphic {
                
        try await Renderer.render(
            name: "Color",
            shaderName: "color",
            uniforms: ColorUniforms(color: color.uniform),
            resolution: size.resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
}
