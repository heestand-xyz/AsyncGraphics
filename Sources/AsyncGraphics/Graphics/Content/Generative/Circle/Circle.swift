//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {
    
    private struct CircleUniforms {
        let premultiply: Bool
        let antiAliasing: Bool
        let radius: Float
        let position: PointUniform
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
        let aspectRatio: Float
    }

    static func circle(radius: CGFloat? = nil,
                       center: CGPoint? = nil,
                       color: PixelColor = .white,
                       backgroundColor: PixelColor = .black,
                       size: CGSize) async throws -> Graphic {
        
        let resolution: CGSize = size.resolution
        
        let radius: CGFloat = radius ?? min(size.width, size.height) / 2
        let relativeRadius: CGFloat = radius / size.height
        
        let center: CGPoint = center?.flipY(size: size) ?? (size / 2).asPoint
        let relativePosition: CGPoint = (center - size / 2) / size.height
        
        let edgeRadius: CGFloat = 0.0
        let edgeColor: PixelColor = .clear

        let premultiply: Bool = true
        
        return try await Renderer.render(
            name: "Circle",
            shaderName: "circle",
            uniforms: CircleUniforms(
                premultiply: premultiply,
                antiAliasing: true,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(edgeRadius),
                foregroundColor: color.uniform,
                edgeColor: edgeColor.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: resolution.uniform,
                aspectRatio: Float(resolution.aspectRatio)
            ),
            resolution: resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
}
