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

    static func box(origin: SIMD3<Double>,
                    size: SIMD3<Double>,
                    cornerRadius: Double = 0.0,
                    color: PixelColor = .white,
                    backgroundColor: PixelColor = .black,
                    resolution: SIMD3<Int>) async throws -> Graphic3D {
        
        let center: SIMD3<Double> = SIMD3<Double>(
            origin.x + size.x / 2,
            origin.y + size.y / 2,
            origin.z + size.z / 2
        )
        
        return try await box(
            center: center,
            size: size,
            cornerRadius: cornerRadius,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution
        )
    }
    
    static func box(center: SIMD3<Double>,
                    size: SIMD3<Double>,
                    cornerRadius: Double = 0.0,
                    color: PixelColor = .white,
                    backgroundColor: PixelColor = .black,
                    resolution: SIMD3<Int>) async throws -> Graphic3D {

        let relativeCenter = SIMD3<Double>(
            (center.x - Double(resolution.x) / 2) / Double(resolution.y),
            (center.y - Double(resolution.y) / 2) / Double(resolution.y),
            (center.z - Double(resolution.z) / 2) / Double(resolution.y)
        )

        let relativeSize: SIMD3<Double> = SIMD3<Double>(
            size.x / Double(resolution.y),
            size.y / Double(resolution.y),
            size.z / Double(resolution.y)
        )
        
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)

        return try await Renderer.render(
            name: "Box",
            shaderName: "box3d",
            uniforms: Box3DUniforms(
                premultiply: true,
                antiAlias: true,
                size: relativeSize.uniform,
                position: relativeCenter.uniform,
                cornerRadius: Float(relativeCornerRadius),
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            resolution: resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
}
