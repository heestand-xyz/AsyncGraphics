//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics

extension Graphic {
    
    private struct SharpenUniforms {
        let sharpness: Float
    }
    
    public func sharpen(_ sharpness: CGFloat = 1.0,
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
