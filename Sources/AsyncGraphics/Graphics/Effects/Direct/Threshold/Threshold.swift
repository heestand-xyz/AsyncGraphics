//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics

extension Graphic {
    
    private struct ThresholdUniforms {
        let fraction: Float
    }
    
    public func threshold(_ fraction: CGFloat = 0.5,
                          options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Threshold",
            shader: .name("threshold"),
            graphics: [self],
            uniforms: ThresholdUniforms(
                fraction: Float(fraction)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
