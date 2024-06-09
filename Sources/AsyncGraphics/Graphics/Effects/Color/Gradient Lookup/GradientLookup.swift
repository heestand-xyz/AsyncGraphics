//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic {
    
    private struct GradientLookupUniforms {
        let gamma: Float
    }
    
    public func sepia(
        color: PixelColor,
        gamma: CGFloat = 1.0,
        options: EffectOptions = []
    ) async throws -> Graphic {
        try await gradientLookup(
            stops: [
                Graphic.GradientStop(at: 0.0, color: .black),
                Graphic.GradientStop(at: 0.5, color: color),
                Graphic.GradientStop(at: 1.0, color: .white),
            ],
            gamma: gamma,
            options: options
        )
    }
    
    public func gradientLookup(
        stops: [GradientStop],
        gamma: CGFloat = 1.0,
        options: EffectOptions = []
    ) async throws -> Graphic {
        try await Renderer.render(
            name: "Gradient Lookup",
            shader: .name("gradientLookup"),
            graphics: [
                self
            ],
            uniforms: GradientLookupUniforms(
                gamma: Float(gamma)
            ),
            arrayUniforms: stops.map { stop in
                GradientColorStopUniforms(
                    fraction: Float(stop.location),
                    color: stop.color.uniform
                )
            },
            emptyArrayUniform: GradientColorStopUniforms(
                fraction: 0.0,
                color: PixelColor.clear.uniform
            ),
            options: options.colorRenderOptions
        )
    }
}
