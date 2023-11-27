//
//  Created by Anton Heestand on 2022-04-11.
//

import simd
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
    
    public static func box(size: SIMD3<Double>? = nil,
                           origin: SIMD3<Double>,
                           cornerRadius: Double = 0.0,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .clear,
                           resolution: SIMD3<Int>,
                           options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: SIMD3<Double> = size ?? SIMD3<Double>(resolution)
        
        let center: SIMD3<Double> = SIMD3<Double>(
            origin.x + size.x / 2,
            origin.y + size.y / 2,
            origin.z + size.z / 2
        )
        
        return try await box(
            size: size,
            center: center,
            cornerRadius: cornerRadius,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            options: options
        )
    }
    
    public static func box(size: SIMD3<Double>? = nil,
                           center: SIMD3<Double>? = nil,
                           cornerRadius: Double = 0.0,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .clear,
                           resolution: SIMD3<Int>,
                           options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: SIMD3<Double> = size ?? SIMD3<Double>(resolution)
        let relativeSize: SIMD3<Double> = size / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)
        
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
    
    public static func surfaceBox(size: SIMD3<Double>? = nil,
                                  origin: SIMD3<Double>,
                                  cornerRadius: Double = 0.0,
                                  surfaceWidth: Double,
                                  color: PixelColor = .white,
                                  backgroundColor: PixelColor = .clear,
                                  resolution: SIMD3<Int>,
                                  options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: SIMD3<Double> = size ?? SIMD3<Double>(resolution)
        
        let center: SIMD3<Double> = SIMD3<Double>(
            origin.x + size.x / 2,
            origin.y + size.y / 2,
            origin.z + size.z / 2
        )
        
        return try await surfaceBox(
            size: size,
            center: center,
            cornerRadius: cornerRadius,
            surfaceWidth: surfaceWidth,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            options: options
        )
    }
    
    public static func surfaceBox(size: SIMD3<Double>? = nil,
                                  center: SIMD3<Double>? = nil,
                                  cornerRadius: Double = 0.0,
                                  surfaceWidth: Double,
                                  color: PixelColor = .white,
                                  backgroundColor: PixelColor = .clear,
                                  resolution: SIMD3<Int>,
                                  options: ContentOptions = []) async throws -> Graphic3D {
        
        let size: SIMD3<Double> = size ?? (SIMD3<Double>(resolution) - surfaceWidth)
        let relativeSize: SIMD3<Double> = size / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)
        
        let relativeSurfaceWidth: Double = surfaceWidth / Double(resolution.y)
        
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
