//
//  Created by Anton Heestand on 2022-04-03.
//

import simd
import PixelColor

public extension Graphic3D {
    
    private struct Sphere3DUniforms {
        let radius: Float
        let position: VectorUniform
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
        let premultiply: Bool
    };

    static func circle(radius: Double? = nil,
                       center: SIMD3<Double>? = nil,
                       color: PixelColor = .white,
                       backgroundColor: PixelColor = .black,
                       resolution: SIMD3<Int>) async throws -> Graphic3D {
        
        let radius: Double = radius ?? Double(min(resolution.x, resolution.y, resolution.z)) / 2
        let relativeRadius: Double = radius / Double(resolution.y)
        
        let center: SIMD3<Double> = center ?? SIMD3<Double>(Double(resolution.x / 2),
                                                            Double(resolution.y / 2),
                                                            Double(resolution.z / 2))
        let relativePosition = SIMD3<Double>((center.x - Double(resolution.x) / 2) / Double(resolution.x),
                                             (center.y - Double(resolution.y) / 2) / Double(resolution.y),
                                             (center.z - Double(resolution.z) / 2) / Double(resolution.z))
        
        let edgeRadius: Double = 0.0
        let edgeColor: PixelColor = .clear

        let premultiply: Bool = true
        
        return try await Renderer.render(
            shaderName: "sphere",
            uniforms: Sphere3DUniforms(
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(edgeRadius),
                foregroundColor: color.uniform,
                edgeColor: edgeColor.uniform,
                backgroundColor: backgroundColor.uniform,
                premultiply: premultiply
            ),
            resolution: resolution,
            colorSpace: .sRGB,
            bits: ._8
        )
    }
}
