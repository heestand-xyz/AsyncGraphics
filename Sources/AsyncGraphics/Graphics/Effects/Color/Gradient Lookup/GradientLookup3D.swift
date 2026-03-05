//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic3D {
    
    private struct GradientLookup3DUniforms: Uniforms {
        let gamma: Float
    }
    
    public func gradientLookup(
        stops: [Graphic.GradientStop],
        gamma: CGFloat = 1.0,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        var colorStops: [Graphic.GradientColorStopUniforms] = stops.map { stop in
            Graphic.GradientColorStopUniforms(
                fraction: Float(stop.location),
                color: stop.color.uniform
            )
        }
        
        if !colorStops.contains(where: { $0.fraction == 0.0 }) {
            colorStops.insert(Graphic.GradientColorStopUniforms(fraction: 0.0, color: colorStops.sorted(by: { $0.fraction < $1.fraction }).first?.color ?? .clear), at: 0)
        }
        
        if !colorStops.contains(where: { $0.fraction == 1.0 }) {
            colorStops.append(Graphic.GradientColorStopUniforms(fraction: 1.0, color: colorStops.sorted(by: { $0.fraction < $1.fraction }).last?.color ?? .clear))
        }
        
        return try await Renderer.render(
            name: "Gradient Lookup 3D",
            shader: .name("gradientLookup3d"),
            graphics: [
                self
            ],
            uniforms: GradientLookup3DUniforms(
                gamma: Float(gamma)
            ),
            arrayUniforms: colorStops,
            emptyArrayUniform: Graphic.GradientColorStopUniforms(
                fraction: 0.0,
                color: PixelColor.clear.uniform
            ),
            options: options.colorRenderOptions
        )
    }
}
