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
        let tileOrigin: PointUniform
        let tileSize: SizeUniform
    }
    
    public static func rectangle(size: CGSize? = nil,
                                 position: CGPoint? = nil,
                                 cornerRadius: CGFloat = 0.0,
                                 color: PixelColor = .white,
                                 backgroundColor: PixelColor = .black,
                                 resolution: CGSize,
                                 tile: Tile = .one,
                                 options: ContentOptions = []) async throws -> Graphic {
        
        let size: CGSize = size ?? resolution
        
        let position: CGPoint = position ?? resolution.asPoint / 2
        let frame = CGRect(origin: position - size / 2, size: size)
        
        var cornerRadius: CGFloat = cornerRadius
        if cornerRadius > 0.0 {
            let minimum = min(size.width, size.height)
            if cornerRadius > minimum / 2 {
                cornerRadius = minimum / 2
            }
        }
        
        return try await rectangle(
            frame: frame,
            cornerRadius: cornerRadius,
            color: color,
            backgroundColor: backgroundColor,    
            resolution: resolution,
            tile: tile,
            options: options
        )
    }
    
    public static func rectangle(frame: CGRect,
                                 cornerRadius: CGFloat = 0.0,
                                 color: PixelColor = .white,
                                 backgroundColor: PixelColor = .black,
                                 resolution: CGSize,
                                 tile: Tile = .one,
                                 options: ContentOptions = []) async throws -> Graphic {
        
        let relativeSize: CGSize = frame.size / resolution.height
        
        let relativePosition: CGPoint = (frame.center - resolution / 2) / resolution.height
        
        let relativeCornerRadius: CGFloat = cornerRadius / resolution.height
        
        return try await Renderer.render(
            name: "Rectangle",
            shader: .name("rectangle"),
            uniforms: RectangleUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func strokedRectangle(size: CGSize? = nil,
                                        position: CGPoint? = nil,
                                        cornerRadius: CGFloat = 0.0,
                                        lineWidth: CGFloat = 1.0,
                                        color: PixelColor = .white,
                                        backgroundColor: PixelColor = .black,
                                        resolution: CGSize,
                                        tile: Tile = .one,
                                        options: ContentOptions = []) async throws -> Graphic {
        
        let size: CGSize = size ?? resolution
        
        let position: CGPoint = position ?? resolution.asPoint / 2
        let frame = CGRect(origin: position - size / 2, size: size)
        
        return try await strokedRectangle(
            frame: frame,
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            tile: tile,
            options: options
        )
    }
    
    public static func strokedRectangle(frame: CGRect,
                                        cornerRadius: CGFloat = 0.0,
                                        lineWidth: CGFloat = 1.0,
                                        color: PixelColor = .white,
                                        backgroundColor: PixelColor = .black,
                                        resolution: CGSize,
                                        tile: Tile = .one,
                                        options: ContentOptions = []) async throws -> Graphic {
        
        let relativeSize: CGSize = frame.size / resolution.height
        
        let relativePosition: CGPoint = (frame.center - resolution / 2) / resolution.height
        
        let relativeCornerRadius: CGFloat = cornerRadius / resolution.height
        
        let relativeLineWidth: CGFloat = lineWidth / resolution.height
        
        return try await Renderer.render(
            name: "Rectangle",
            shader: .name("rectangle"),
            uniforms: RectangleUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: Float(relativeLineWidth),
                foregroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                edgeColor: color.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
