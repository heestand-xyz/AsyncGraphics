//
//  Created by Anton Heestand on 2022-09-13.
//

import CoreGraphics
import PixelColor

extension Graphic3D {
    
    private struct Clamp3DUniforms {
        let includeAlpha: Bool
        let type: UInt32
        let low: Float
        let high: Float
    }
    
    public func clamp(
        _ type: Graphic.ClampType = .relative,
        low: CGFloat = 0.0,
        high: CGFloat = 1.0,
        includeAlpha: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Clamp 3D",
            shader: .name("clamp3d"),
            graphics: [self],
            uniforms: Clamp3DUniforms(
                includeAlpha: includeAlpha,
                type: type.index,
                low: Float(low),
                high: Float(high)
            ),
            options: options.renderOptions
        )
    }
}
