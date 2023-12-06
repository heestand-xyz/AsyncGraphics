//
//  Created by Anton Heestand on 2022-04-11.
//

import Spatial
import PixelColor

extension Graphic3D {
    
    private struct Box3DUniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let size: VectorUniform
        let position: VectorUniform
        let cornerRadius: Float
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
    }
    
    public static func box(size: Size3D? = nil,
                           origin: Point3D,
                           cornerRadius: Double = 0.0,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .clearWhite,
                           resolution: Size3D,
                           options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: Size3D = size ?? resolution
        
        let position: Point3D = origin + size / 2
        
        return try await box(
            size: size,
            position: position,
            cornerRadius: cornerRadius,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            options: options
        )
    }
    
    public static func box(size: Size3D? = nil,
                           position: Point3D? = nil,
                           cornerRadius: Double = 0.0,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .clearWhite,
                           resolution: Size3D,
                           options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: Size3D = size ?? resolution
        let relativeSize: Size3D = size / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition: Point3D = (position - resolution / 2) / resolution.height
        
        let relativeCornerRadius: Double = cornerRadius / resolution.height
        
        return try await Renderer.render(
            name: "Box 3D",
            shader: .name("box3d"),
            uniforms: Box3DUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
    
    public static func surfaceBox(size: Size3D? = nil,
                                  origin: Point3D,
                                  cornerRadius: Double = 0.0,
                                  surfaceWidth: Double,
                                  color: PixelColor = .white,
                                  backgroundColor: PixelColor = .clearWhite,
                                  resolution: Size3D,
                                  options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: Size3D = size ?? resolution
        
        let position: Point3D = origin + size / 2
        
        return try await surfaceBox(
            size: size,
            position: position,
            cornerRadius: cornerRadius,
            surfaceWidth: surfaceWidth,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            options: options
        )
    }
    
    public static func surfaceBox(size: Size3D? = nil,
                                  position: Point3D? = nil,
                                  cornerRadius: Double = 0.0,
                                  surfaceWidth: Double,
                                  color: PixelColor = .white,
                                  backgroundColor: PixelColor = .clearWhite,
                                  resolution: Size3D,
                                  options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: Size3D = size ?? (resolution - Size3D(width: surfaceWidth, height: surfaceWidth, depth: surfaceWidth))
        let relativeSize: Size3D = size / resolution.height
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition = (position - Point3D(resolution) / 2) / resolution.height
        
        let relativeCornerRadius: Double = cornerRadius / resolution.height
        
        let relativeSurfaceWidth: Double = surfaceWidth / resolution.height
        
        return try await Renderer.render(
            name: "Box 3D",
            shader: .name("box3d"),
            uniforms: Box3DUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: Float(relativeSurfaceWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
