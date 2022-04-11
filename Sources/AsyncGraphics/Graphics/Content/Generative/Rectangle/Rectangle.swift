//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {
    
    private struct RectangleUniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let size: SizeUniform
        let position: PointUniform
        let cornerRadius: Float
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
    }
    
    static func rectangle(frame: CGRect,
                          cornerRadius: CGFloat = 0.0,
                          color: PixelColor = .white,
                          backgroundColor: PixelColor = .black,
                          size: CGSize) async throws -> Graphic {
        
        let relativeSize: CGSize = frame.size / size.height
        
        let relativePosition: CGPoint = (frame.center - size / 2) / size.height
        
        let relativeCornerRadius: CGFloat = cornerRadius / size.height
        
        return try await Renderer.render(
            name: "Rectangle",
            shaderName: "rectangle",
            uniforms: RectangleUniforms(
                premultiply: true,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: Float(0.1),
                foregroundColor: color.uniform,
                edgeColor: PixelColor.gray.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: size.resolution.uniform
            ),
            resolution: size.resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
    
    static func strokedRectangle(frame: CGRect,
                                 cornerRadius: CGFloat = 0.0,
                                 lineWidth: CGFloat,
                                 color: PixelColor = .white,
                                 backgroundColor: PixelColor = .black,
                                 size: CGSize) async throws -> Graphic {
        
        let relativeSize: CGSize = frame.size / size.height
        
        let relativePosition: CGPoint = (frame.center - size / 2) / size.height
        
        let relativeCornerRadius: CGFloat = cornerRadius / size.height

        let relativeLineWidth: CGFloat = lineWidth / size.height

        return try await Renderer.render(
            name: "Rectangle",
            shaderName: "rectangle",
            uniforms: RectangleUniforms(
                premultiply: true,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
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
