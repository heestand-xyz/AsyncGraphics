//
//  Created by Anton Heestand on 2022-05-23.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic3D {
    
    private struct Gradient3DUniforms {
        let type: Int32
        let extend: Int32
        let scale: Float
        let offset: Float
        let position: VectorUniform
        let gamma: Float
        let premultiply: Bool
        let resolution: VectorUniform
    }
    
    public enum Gradient3DDirection: Int32 {
        case x
        case y
        case z
        case radial
    }
    
    public static func gradient(direction: Gradient3DDirection,
                                stops: [Graphic.GradientStop] = [
                                    Graphic.GradientStop(at: 0.0, color: .black),
                                    Graphic.GradientStop(at: 1.0, color: .white)
                                ],
                                center: SIMD3<Double>? = nil,
                                scale: CGFloat = 1.0,
                                offset: CGFloat = 0.0,
                                extend: Graphic.GradientExtend = .zero,
                                gamma: CGFloat = 1.0,
                                resolution: SIMD3<Int>,
                                options: ContentOptions = []) async throws -> Graphic3D {
        
        let center: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativePosition: SIMD3<Double> = (center - SIMD3<Double>(resolution) / 2) / Double(resolution.y)
        
        return try await Renderer.render(
            name: "Gradient 3D",
            shader: .name("gradient3d"),
            uniforms: Gradient3DUniforms(
                type: direction.rawValue,
                extend: extend.rawValue,
                scale: Float(scale),
                offset: Float(offset),
                position: relativePosition.uniform,
                gamma: Float(gamma),
                premultiply: options.premultiply,
                resolution: SIMD3<Double>(resolution).uniform
            ),
            arrayUniforms: stops.map { stop in
                Graphic.GradientColorStopUniforms(
                    fraction: Float(stop.location),
                    color: stop.color.uniform
                )
            },
            emptyArrayUniform: Graphic.GradientColorStopUniforms(
                fraction: 0.0,
                color: PixelColor.clear.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
