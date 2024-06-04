//
//  Created by Anton Heestand on 2022-09-13.
//

import CoreGraphics
import PixelColor

extension Graphic3D {
    
    private struct Range3DUniforms {
        let includeAlpha: Bool
        let inLow: Float
        let inHigh: Float
        let outLow: Float
        let outHigh: Float
    }
    
    public func range(
        referenceLow: CGFloat = 0.0,
        referenceHigh: CGFloat = 1.0,
        targetLow: CGFloat = 0.0,
        targetHigh: CGFloat = 1.0,
        includeAlpha: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Range 3D",
            shader: .name("range3d"),
            graphics: [self],
            uniforms: Range3DUniforms(
                includeAlpha: includeAlpha,
                inLow: Float(referenceLow),
                inHigh: Float(referenceHigh),
                outLow: Float(targetLow),
                outHigh: Float(targetHigh)
            )
        )
    }
}
