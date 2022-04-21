//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
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
    
    public static func rectangle(size: CGSize,
                                 center: CGPoint? = nil,
                                 cornerRadius: CGFloat = 0.0,
                                 color: PixelColor = .white,
                                 backgroundColor: PixelColor = .black,
                                 at graphicSize: CGSize,
                                 options: Options = Options()) async throws -> Graphic {
        
        let center: CGPoint = center ?? graphicSize.asPoint / 2
        let frame = CGRect(origin: center - size / 2, size: size)
        
        return try await rectangle(
            frame: frame,
            cornerRadius: cornerRadius,
            color: color,
            backgroundColor: backgroundColor,    
            at: graphicSize,
            options: options
        )
    }
    
    public static func rectangle(frame: CGRect,
                                 cornerRadius: CGFloat = 0.0,
                                 color: PixelColor = .white,
                                 backgroundColor: PixelColor = .black,
                                 at graphicSize: CGSize,
                                 options: Options = Options()) async throws -> Graphic {
        
        let frame = frame.flipY(size: graphicSize)
        
        let relativeSize: CGSize = frame.size / graphicSize.height
        
        let relativePosition: CGPoint = (frame.center - graphicSize / 2) / graphicSize.height
        
        let relativeCornerRadius: CGFloat = cornerRadius / graphicSize.height
        
        return try await Renderer.render(
            name: "Rectangle",
            shader: .name("rectangle"),
            uniforms: RectangleUniforms(
                premultiply: true,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
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
    
    public static func strokedRectangle(size: CGSize,
                                        center: CGPoint? = nil,
                                        cornerRadius: CGFloat = 0.0,
                                        lineWidth: CGFloat,
                                        color: PixelColor = .white,
                                        backgroundColor: PixelColor = .black,
                                        at graphicSize: CGSize,
                                        options: Options = Options()) async throws -> Graphic {
        
        let center: CGPoint = center ?? graphicSize.asPoint / 2
        let frame = CGRect(origin: center - size / 2, size: size)
        
        return try await strokedRectangle(
            frame: frame,
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            color: color,
            backgroundColor: backgroundColor,
            at: graphicSize,
            options: options
        )
    }
    
    public static func strokedRectangle(frame: CGRect,
                                        cornerRadius: CGFloat = 0.0,
                                        lineWidth: CGFloat,
                                        color: PixelColor = .white,
                                        backgroundColor: PixelColor = .black,
                                        at graphicSize: CGSize,
                                        options: Options = Options()) async throws -> Graphic {
        
        let frame = frame.flipY(size: graphicSize)
        
        let relativeSize: CGSize = frame.size / graphicSize.height
        
        let relativePosition: CGPoint = (frame.center - graphicSize / 2) / graphicSize.height
        
        let relativeCornerRadius: CGFloat = cornerRadius / graphicSize.height
        
        let relativeLineWidth: CGFloat = lineWidth / graphicSize.height
        
        return try await Renderer.render(
            name: "Rectangle",
            shader: .name("rectangle"),
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
