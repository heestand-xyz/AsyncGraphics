//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
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
    
    public static func circle(radius: CGFloat? = nil,
                              center: CGPoint? = nil,
                              color: PixelColor = .white,
                              backgroundColor: PixelColor = .black,
                              resolution: CGSize,
                              options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? min(resolution.width, resolution.height) / 2
        
        let relativeRadius: CGFloat = radius / resolution.height
        
        let center: CGPoint = center ?? (resolution.asPoint / 2)
        let relativePosition: CGPoint = (center - resolution / 2) / resolution.height
        
        return try await Renderer.render(
            name: "Circle",
            shader: .name("circle"),
            uniforms: CircleUniforms(
                premultiply: options.premultiply,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func strokedCircle(radius: CGFloat? = nil,
                                     center: CGPoint? = nil,
                                     lineWidth: CGFloat = 1,
                                     color: PixelColor = .white,
                                     backgroundColor: PixelColor = .black,
                                     resolution: CGSize,
                                     options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? (min(resolution.width, resolution.height) / 2 - lineWidth / 2)
        
        let relativeRadius: CGFloat = radius / resolution.height
        
        let center: CGPoint = center ?? (resolution / 2).asPoint
        let relativePosition: CGPoint = (center - resolution / 2) / resolution.height
        
        let relativeLineWidth: CGFloat = lineWidth / resolution.height
        
        return try await Renderer.render(
            name: "Circle",
            shader: .name("circle"),
            uniforms: CircleUniforms(
                premultiply: options.premultiply,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(relativeLineWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
