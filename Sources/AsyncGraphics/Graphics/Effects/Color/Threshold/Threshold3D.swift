//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import PixelColor

extension Graphic3D {
    
    private struct Threshold3DUniforms: Uniforms {
        let fraction: Float
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
    }
    
    public func threshold(
        _ fraction: CGFloat = 0.5,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .clear,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Threshold 3D",
            shader: .name("threshold3d"),
            graphics: [self], 
            uniforms: Threshold3DUniforms(
                fraction: Float(fraction),
                foregroundColor: color.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            options: options.colorRenderOptions
        )
    }
}
