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
        let tileOrigin: PointUniform
        let tileSize: SizeUniform
    }
    
    public static func circle(radius: CGFloat? = nil,
                              position: CGPoint? = nil,
                              color: PixelColor = .white,
                              backgroundColor: PixelColor = .black,
                              resolution: CGSize,
                              tile: Tile = .one,
                              options: ContentOptions = []) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? min(resolution.width, resolution.height) / 2
        
        let relativeRadius: CGFloat = radius / resolution.height
        
        let position: CGPoint = position ?? (resolution.asPoint / 2)
        let relativePosition: CGPoint = (position - resolution / 2) / resolution.height
        
        return try await Renderer.render(
            name: "Circle",
            shader: .name("circle"),
            uniforms: CircleUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
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
    
    public static func strokedCircle(radius: CGFloat? = nil,
                                     position: CGPoint? = nil,
                                     lineWidth: CGFloat = 1.0,
                                     color: PixelColor = .white,
                                     backgroundColor: PixelColor = .black,
                                     resolution: CGSize,
                                     tile: Tile = .one,
                                     options: ContentOptions = []) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? (min(resolution.width, resolution.height) / 2 - lineWidth / 2)
        
        let relativeRadius: CGFloat = radius / resolution.height
        
        let position: CGPoint = position ?? (resolution / 2).asPoint
        let relativePosition: CGPoint = (position - resolution / 2) / resolution.height
        
        let relativeLineWidth: CGFloat = lineWidth / resolution.height
        
        return try await Renderer.render(
            name: "Circle",
            shader: .name("circle"),
            uniforms: CircleUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(relativeLineWidth),
                foregroundColor: backgroundColor.uniform,
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
