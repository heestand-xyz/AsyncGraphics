//
//  Created by Anton Heestand on 2022-04-04.
//

import simd
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic3D {
    
    private struct Color3DUniforms {
        let premultiply: Bool
        let color: ColorUniform
    }
    
    public static func color(_ color: PixelColor, at resolution: SIMD3<Int>) async throws -> Graphic3D {
                
        try await Renderer.render(
            name: "Color",
            shaderName: "color3d",
            uniforms: Color3DUniforms(
                premultiply: true,
                color: color.uniform
            ),
            metadata: Metadata(
                resolution: resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
}
