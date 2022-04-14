//
//  Created by Anton Heestand on 2022-04-11.
//

import simd
import PixelColor

public extension Graphic3D {

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

    static func box(size: SIMD3<Double>,
                    origin: SIMD3<Double>,
                    cornerRadius: Double = 0.0,
                    color: PixelColor = .white,
                    backgroundColor: PixelColor = .black,
                    at resolution: SIMD3<Int>) async throws -> Graphic3D {
        
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
            at: resolution
        )
    }
    
    static func box(size: SIMD3<Double>,
                    center: SIMD3<Double>? = nil,
                    cornerRadius: Double = 0.0,
                    color: PixelColor = .white,
                    backgroundColor: PixelColor = .black,
                    at resolution: SIMD3<Int>) async throws -> Graphic3D {
        
        let relativeSize: SIMD3<Double> = SIMD3<Double>(
            size.x / Double(resolution.y),
            size.y / Double(resolution.y),
            size.z / Double(resolution.y)
        )
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(
            Double(resolution.x) / 2,
            Double(resolution.y) / 2,
            Double(resolution.z) / 2
        )
        let relativePosition = SIMD3<Double>(
            (position.x - Double(resolution.x) / 2) / Double(resolution.y),
            (position.y - Double(resolution.y) / 2) / Double(resolution.y),
            (position.z - Double(resolution.z) / 2) / Double(resolution.y)
        )
        
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)

        return try await Renderer.render(
            name: "Box",
            shaderName: "box3d",
            uniforms: Box3DUniforms(
                premultiply: true,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            metadata: Metadata(
                resolution: resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
    
    static func surfaceBox(size: SIMD3<Double>,
                           origin: SIMD3<Double>,
                           cornerRadius: Double = 0.0,
                           surfaceWidth: Double,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .black,
                           at resolution: SIMD3<Int>) async throws -> Graphic3D {
        
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
            at: resolution
        )
    }
    
    static func surfaceBox(size: SIMD3<Double>,
                           center: SIMD3<Double>? = nil,
                           cornerRadius: Double = 0.0,
                           surfaceWidth: Double,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .black,
                           at resolution: SIMD3<Int>) async throws -> Graphic3D {
        
        let relativeSize: SIMD3<Double> = SIMD3<Double>(
            size.x / Double(resolution.y),
            size.y / Double(resolution.y),
            size.z / Double(resolution.y)
        )
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(
            Double(resolution.x) / 2,
            Double(resolution.y) / 2,
            Double(resolution.z) / 2
        )
        let relativePosition = SIMD3<Double>(
            (position.x - Double(resolution.x) / 2) / Double(resolution.y),
            (position.y - Double(resolution.y) / 2) / Double(resolution.y),
            (position.z - Double(resolution.z) / 2) / Double(resolution.y)
        )
        
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)
        
        let relativeSurfaceWidth: Double = surfaceWidth / Double(resolution.y)

        return try await Renderer.render(
            name: "Box",
            shaderName: "box3d",
            uniforms: Box3DUniforms(
                premultiply: true,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativePosition.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: Float(relativeSurfaceWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            metadata: Metadata(
                resolution: resolution,
                colorSpace: .sRGB,
                bits: ._8
            )
        )
    }
}