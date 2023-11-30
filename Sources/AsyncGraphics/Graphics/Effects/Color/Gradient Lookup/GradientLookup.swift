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
    
    public func gradientLookup(stops: [GradientStop],
                               gamma: CGFloat = 1.0,
                               options: EffectOptions = []) async throws -> Graphic {
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
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
