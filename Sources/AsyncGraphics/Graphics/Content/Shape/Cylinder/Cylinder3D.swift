//
//  Created by Anton Heestand on 2022-04-03.
//

import simd
import PixelColor

extension Graphic3D {
    
    private struct Cylinder3DUniforms {
        let axis: UInt32
        let premultiply: Bool
        let antiAlias: Bool
        let radius: Float
        let length: Float
        let cornerRadius: Float
        let position: VectorUniform
        let surfaceWidth: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
    }
    
    public static func cylinder(axis: Axis = .z,
                                radius: Double? = nil,
                                length: Double? = nil,
                                cornerRadius: Double = 0.0,
                                center: SIMD3<Double>? = nil,
                                color: PixelColor = .white,
                                backgroundColor: PixelColor = .clear,
                                resolution: SIMD3<Int>,
                                options: ContentOptions = []) async throws -> Graphic3D {
        
        let radius: Double = radius ?? Double(min(resolution.x, resolution.y, resolution.z)) / 2
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let length: Double = length ?? Double({
            switch axis {
            case .x:
                resolution.x
            case .y:
                resolution.y
            case .z:
                resolution.z
            }
        }())
        let relativeLength: Double = length / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Cylinder 3D",
            shader: .name("cylinder3d"),
            uniforms: Cylinder3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                length: Float(relativeLength),
                cornerRadius: Float(relativeCornerRadius),
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
    
    public static func surfaceCylinder(axis: Axis = .z,
                                       radius: Double? = nil,
                                       length: Double? = nil,
                                       cornerRadius: Double = 0.0,
                                       center: SIMD3<Double>? = nil,
                                       surfaceWidth: Double,
                                       color: PixelColor = .white,
                                       backgroundColor: PixelColor = .clear,
                                       resolution: SIMD3<Int>,
                                       options: ContentOptions = []) async throws -> Graphic3D {
        
        let radius: Double = radius ?? (Double(min(resolution.x, resolution.y, resolution.z)) / 2 - surfaceWidth / 2)
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let length: Double = length ?? Double({
            switch axis {
            case .x:
                resolution.x
            case .y:
                resolution.y
            case .z:
                resolution.z
            }
        }()) - surfaceWidth
        let relativeLength: Double = length / Double(resolution.y)
        
        let position: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition = (position - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        let relativeSurfaceWidth: Double = surfaceWidth / Double(resolution.y)
        
        let relativeCornerRadius: Double = cornerRadius / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Cylinder 3D",
            shader: .name("cylinder3d"),
            uniforms: Cylinder3DUniforms(
                axis: axis.index,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                radius: Float(relativeRadius),
                length: Float(relativeLength),
                cornerRadius: Float(relativeCornerRadius),
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
