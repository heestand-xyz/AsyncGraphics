//
//  Created by Anton Heestand on 2022-04-03.
//

import simd
import PixelColor

public extension Graphic3D {
    
    private struct Sphere3DUniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let radius: Float
        let position: VectorUniform
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
    }

    static func sphere(radius: Double,
                       center: SIMD3<Double>,
                       color: PixelColor = .white,
                       backgroundColor: PixelColor = .black,
                       at resolution: SIMD3<Int>) async throws -> Graphic3D {
        
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let relativeCenter = SIMD3<Double>(
            (center.x - Double(resolution.x) / 2) / Double(resolution.y),
            (center.y - Double(resolution.y) / 2) / Double(resolution.y),
            (center.z - Double(resolution.z) / 2) / Double(resolution.y)
        )
        
        return try await Renderer.render(
            name: "Sphere",
            shaderName: "sphere3d",
            uniforms: Sphere3DUniforms(
                premultiply: true,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativeCenter.uniform,
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
    
    static func surfaceSphere(radius: Double,
                              center: SIMD3<Double>,
                              surfaceWidth: Double,
                              color: PixelColor = .white,
                              backgroundColor: PixelColor = .black,
                              at resolution: SIMD3<Int>) async throws -> Graphic3D {
        
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let relativeCenter = SIMD3<Double>(
            (center.x - Double(resolution.x) / 2) / Double(resolution.y),
            (center.y - Double(resolution.y) / 2) / Double(resolution.y),
            (center.z - Double(resolution.z) / 2) / Double(resolution.y)
        )
        
        let relativeSurfaceWidth: Double = surfaceWidth / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Sphere",
            shaderName: "sphere3d",
            uniforms: Sphere3DUniforms(
                premultiply: true,
                antiAlias: true,
                radius: Float(relativeRadius),
                position: relativeCenter.uniform,
                edgeRadius: Float(relativeSurfaceWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            resolution: resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
}
