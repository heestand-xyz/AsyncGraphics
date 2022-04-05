//
//  Created by Anton Heestand on 2022-04-04.
//

//import simd
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {
    
    struct ColorUniforms {
        let color: ColorUniform
//        let color: SIMD4<Float>
    }
    
    static func color(_ color: PixelColor, size: CGSize) async throws -> Graphic {
                
        let texture = try await Renderer.render(
            shaderName: "color",
            uniforms: ColorUniforms(color: color.uniform),
            resolution: size.resolution,
            bits: ._8
        )
        
        return Graphic(texture: texture, bits: ._8, colorSpace: .sRGB)
    }
}
