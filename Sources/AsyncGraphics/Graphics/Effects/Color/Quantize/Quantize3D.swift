//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Quantize3DUniforms {
        let fraction: Float
    }
    
    public func quantize(
        _ fraction: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Quantize 3D",
            shader: .name("quantize3d"),
            graphics: [self],
            uniforms: Quantize3DUniforms(
                fraction: Float(fraction)
            ),
            options: options.renderOptions
        )
    }
}
