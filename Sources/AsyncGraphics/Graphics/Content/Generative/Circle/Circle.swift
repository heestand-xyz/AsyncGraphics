//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {
    
    private struct CircleUniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let radius: Float
        let position: PointUniform
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
    }

    static func circle(radius: CGFloat? = nil,
                       center: CGPoint? = nil,
                       color: PixelColor = .white,
                       backgroundColor: PixelColor = .black,
                       size: CGSize) async throws -> Graphic {
                
        let radius: CGFloat = radius ?? min(size.width, size.height) / 2
        let relativeRadius: CGFloat = radius / size.height
        
        let center: CGPoint = center?.flipY(size: size) ?? (size / 2).asPoint
        let relativePosition: CGPoint = (center - size / 2) / size.height
        
        return try await Renderer.render(
            name: "Circle",
            shaderName: "circle",
            uniforms: CircleUniforms(
                premultiply: true,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: size.resolution.uniform
            ),
            resolution: size.resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
    
    static func strokedCircle(radius: CGFloat? = nil,
                              center: CGPoint? = nil,
                              lineWidth: CGFloat,
                              color: PixelColor = .white,
                              backgroundColor: PixelColor = .black,
                              size: CGSize) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? min(size.width, size.height) / 2
        let relativeRadius: CGFloat = radius / size.height
        
        let center: CGPoint = center?.flipY(size: size) ?? (size / 2).asPoint
        let relativePosition: CGPoint = (center - size / 2) / size.height

        let relativeLineWidth: CGFloat = lineWidth / size.height

        return try await Renderer.render(
            name: "Circle",
            shaderName: "circle",
            uniforms: CircleUniforms(
                premultiply: true,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(relativeLineWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: size.resolution.uniform
            ),
            resolution: size.resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
}
