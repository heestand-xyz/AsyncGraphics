//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics

extension Graphic {
    
    private struct SharpenUniforms {
        let sharpness: Float
    }
    
    /// Increases the sharpness of a graphic
    ///
    /// Recommended sharpness value are between 0.0 and 1.0. Higher values are allowed.
    public func sharpen(_ sharpness: CGFloat,
                        options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Sharpen",
            shader: .name("sharpen"),
            graphics: [self],
            uniforms: SharpenUniforms(
                sharpness: Float(sharpness)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
