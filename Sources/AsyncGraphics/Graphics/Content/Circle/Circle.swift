//
//  Created by Anton Heestand on 2022-04-03.
//

//import simd
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {
    
    struct CircleUniforms {
        let radius: Float
        let position: PointUniform
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
        let premultiply: Bool
        let resolution: SizeUniform
        let aspectRatio: Float
//        let radius: Float
//        let position: SIMD2<Float>
//        let edgeRadius: Float
//        let foregroundColor: SIMD4<Float>
//        let edgeColor: SIMD4<Float>
//        let backgroundColor: SIMD4<Float>
//        let premultiply: Bool
//        let resolution: SIMD2<Float>
//        let aspectRatio: Float
    }

    static func circle(size: CGSize,
                       radius: CGFloat? = nil,
                       center: CGPoint? = nil,
                       color: PixelColor = .white,
                       backgroundColor: PixelColor = .black) async throws -> Graphic {
        
        let resolution: CGSize = size.resolution
        
        let radius: CGFloat = radius ?? min(size.width, size.height) / 2
        let relativeRadius: CGFloat = radius / size.height
        
        let center: CGPoint = center?.flipY(size: size) ?? (size / 2).asPoint
        let relativePosition: CGPoint = (center - size / 2) / size.height
        
        let edgeRadius: CGFloat = 0.0
        let edgeColor: PixelColor = .clear

        let premultiply: Bool = true
        
        let texture = try await Renderer.render(
            shaderName: "circle",
            uniforms: CircleUniforms(
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(edgeRadius),
                foregroundColor: color.uniform,
                edgeColor: edgeColor.uniform,
                backgroundColor: backgroundColor.uniform,
                premultiply: premultiply,
                resolution: resolution.uniform,
                aspectRatio: Float(resolution.aspectRatio)
            ),
            resolution: resolution,
            bits: ._8
        )
        
        return Graphic(texture: texture, bits: ._8, colorSpace: .sRGB)
    }
}
