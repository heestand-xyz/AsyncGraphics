//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct ThresholdUniforms {
        let fraction: Float
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
    }
    
    public func threshold(
        _ fraction: CGFloat = 0.5,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Threshold",
            shader: .name("threshold"),
            graphics: [self],
            uniforms: ThresholdUniforms(
                fraction: Float(fraction),
                foregroundColor: color.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            options: options.colorRenderOptions
        )
    }
}
