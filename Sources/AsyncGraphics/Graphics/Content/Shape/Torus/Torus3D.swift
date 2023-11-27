//
//  Created by Anton Heestand on 2022-04-03.
//

import simd
import PixelColor

extension Graphic3D {
    
    private struct Torus3DUniforms {
        let axis: UInt32
        let premultiply: Bool
        let antiAlias: Bool
        let radius: Float
        let revolvingRadius: Float
        let position: VectorUniform
        let surfaceWidth: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
    }
    
    public static func torus(
        axis: Axis = .z,
        radius: Double? = nil,
        revolvingRadius: Double? = nil,
        center: SIMD3<Double>? = nil,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clear,
        resolution: SIMD3<Int>,
        options: ContentOptions = []
    ) async throws -> Graphic3D {
        
        let radius: Double = radius ?? Double(min(resolution.x, resolution.y, resolution.z)) / 4
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let revolvingRadius: Double = revolvingRadius ?? Double(min(resolution.x, resolution.y, resolution.z)) / 8
        let relativeRevolvingRadius: Double = revolvingRadius / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Torus 3D",
            shader: .name("torus3d"),
            uniforms: Torus3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                revolvingRadius: Float(relativeRevolvingRadius),
                position: relativePosition.uniform,
                surfaceWidth: 0.0,
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
    
    public static func surfaceTorus(
        axis: Axis = .z,
        radius: Double? = nil,
        revolvingRadius: Double? = nil,
        center: SIMD3<Double>? = nil,
        surfaceWidth: Double,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clear,
        resolution: SIMD3<Int>,
        options: ContentOptions = []
    ) async throws -> Graphic3D {
        
        let radius: Double = radius ?? Double(min(resolution.x, resolution.y, resolution.z)) / 4
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let revolvingRadius: Double = revolvingRadius ?? Double(min(resolution.x, resolution.y, resolution.z)) / 8
        let relativeRevolvingRadius: Double = revolvingRadius / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        let relativeSurfaceWidth: Double = surfaceWidth / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Torus 3D",
            shader: .name("torus3d"),
            uniforms: Torus3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                revolvingRadius: Float(relativeRevolvingRadius),
                position: relativePosition.uniform,
                surfaceWidth: Float(relativeSurfaceWidth),
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
