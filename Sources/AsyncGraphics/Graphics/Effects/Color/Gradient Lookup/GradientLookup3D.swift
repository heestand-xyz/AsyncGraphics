//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic3D {
    
    private struct GradientLookup3DUniforms {
        let gamma: Float
    }
    
    public func gradientLookup(
        stops: [Graphic.GradientStop],
        gamma: CGFloat = 1.0,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        try await Renderer.render(
            name: "Gradient Lookup 3D",
            shader: .name("gradientLookup3d"),
            graphics: [
                self
            ],
            uniforms: GradientLookup3DUniforms(
                gamma: Float(gamma)
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
            options: options.colorRenderOptions
        )
    }
}
