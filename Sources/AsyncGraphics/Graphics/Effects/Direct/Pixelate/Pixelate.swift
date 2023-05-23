//
//  Created by Anton Heestand on 2023-05-20.
//

import CoreGraphics

extension Graphic {
    
    private struct PixelateUniforms {
        let fraction: Float
    }
    
    /// Pixelate
    /// - Parameters:
    ///   - fraction: A higher value will result in more pixelation.
    ///   A value of 1.0 will result in one pixel, 0.5 in 2x2 and 0.25 in 4x4.
    public func pixelate(_ fraction: CGFloat = 0.1,
                         options: EffectOptions = .edgeStretch) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Pixelate",
            shader: .name("pixelate"),
            graphics: [self],
            uniforms: PixelateUniforms(
                fraction: Float(fraction)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
