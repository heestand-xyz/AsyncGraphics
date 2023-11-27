//
//  Created by Anton Heestand on 2022-04-03.
//

import simd
import PixelColor

extension Graphic3D {
    
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
    
    public static func sphere(radius: Double? = nil,
                              center: SIMD3<Double>? = nil,
                              color: PixelColor = .white,
                              backgroundColor: PixelColor = .clear,
                              resolution: SIMD3<Int>,
                              options: ContentOptions = []) async throws -> Graphic3D {
        
        let radius: Double = radius ?? Double(min(resolution.x, resolution.y, resolution.z)) / 2
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Sphere 3D",
            shader: .name("sphere3d"),
            uniforms: Sphere3DUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
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
    
    public static func surfaceSphere(radius: Double? = nil,
                                     center: SIMD3<Double>? = nil,
                                     surfaceWidth: Double,
                                     color: PixelColor = .white,
                                     backgroundColor: PixelColor = .clear,
                                     resolution: SIMD3<Int>,
                                     options: ContentOptions = []) async throws -> Graphic3D {
        
        let radius: Double = radius ?? (Double(min(resolution.x, resolution.y, resolution.z)) / 2 - surfaceWidth / 2)
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        let relativeSurfaceWidth: Double = surfaceWidth / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Sphere 3D",
            shader: .name("sphere3d"),
            uniforms: Sphere3DUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
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
