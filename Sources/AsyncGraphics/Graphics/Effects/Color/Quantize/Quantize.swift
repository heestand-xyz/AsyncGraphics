//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics

extension Graphic {
    
    private struct QuantizeUniforms {
        let fraction: Float
    }
    
    public func quantize(_ fraction: CGFloat,
                         options: EffectOptions = []) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Quantize",
            shader: .name("quantize"),
            graphics: [self],
            uniforms: QuantizeUniforms(
                fraction: Float(fraction)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
