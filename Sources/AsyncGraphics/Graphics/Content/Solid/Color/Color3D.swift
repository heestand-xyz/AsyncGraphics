//
//  Created by Anton Heestand on 2022-04-04.
//

import Spatial
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic3D {
    
    private struct Color3DUniforms: Uniforms {
        let premultiply: Bool
        let color: ColorUniform
    }
    
    public static func color(_ color: PixelColor,
                             resolution: Size3D,
                             options: ContentOptions = []) async throws -> Graphic3D {
                
        try await Renderer.render(
            name: "Color 3D",
            shader: .name("color3d"),
            uniforms: Color3DUniforms(
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
