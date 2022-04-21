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
    
    public static func circle(radius: CGFloat,
                              center: CGPoint? = nil,
                              color: PixelColor = .white,
                              backgroundColor: PixelColor = .black,
                              at graphicSize: CGSize,
                              options: Options = Options()) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / graphicSize.height
        
        let center: CGPoint = center?.flipPositionY(size: graphicSize) ?? (graphicSize.asPoint / 2)
        let relativePosition: CGPoint = (center - graphicSize / 2) / graphicSize.height
        
        return try await Renderer.render(
            name: "Circle",
            shader: .name("circle"),
            uniforms: CircleUniforms(
                premultiply: true,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: graphicSize.resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: options.bits
            )
        )
    }
    
    public static func strokedCircle(radius: CGFloat,
                                     center: CGPoint? = nil,
                                     lineWidth: CGFloat,
                                     color: PixelColor = .white,
                                     backgroundColor: PixelColor = .black,
                                     at graphicSize: CGSize,
                                     options: Options = Options()) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / graphicSize.height
        
        let center: CGPoint = center?.flipPositionY(size: graphicSize) ?? (graphicSize / 2).asPoint
        let relativePosition: CGPoint = (center - graphicSize / 2) / graphicSize.height
        
        let relativeLineWidth: CGFloat = lineWidth / graphicSize.height
        
        return try await Renderer.render(
            name: "Circle",
            shader: .name("circle"),
            uniforms: CircleUniforms(
                premultiply: true,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(relativeLineWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: graphicSize.resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: graphicSize.resolution,
                colorSpace: .sRGB,
                bits: options.bits
            )
        )
    }
}
