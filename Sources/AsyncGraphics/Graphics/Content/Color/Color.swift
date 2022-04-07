//
//  Created by Anton Heestand on 2022-04-04.
//

//import simd
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {
    
    private struct ColorUniforms {
        let color: ColorUniform
//        let color: SIMD4<Float>
    }
    
    static func color(_ color: PixelColor, size: CGSize) async throws -> Graphic {
                
        try await Renderer.render(
            shaderName: "color",
            uniforms: ColorUniforms(color: color.uniform),
            resolution: size.resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
}
