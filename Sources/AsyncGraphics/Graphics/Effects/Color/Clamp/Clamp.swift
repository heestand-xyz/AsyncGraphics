//
//  Created by Anton Heestand on 2022-09-13.
//

import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct ClampUniforms {
        let includeAlpha: Bool
        let type: UInt32
        let low: Float
        let high: Float
    }
    
    @EnumMacro
    public enum ClampType: String, GraphicEnum {
        case hold
        case loop
        case mirror
        case zero
        case relative
    }
    
    public func clamp(
        _ type: ClampType = .relative,
        low: CGFloat = 0.0,
        high: CGFloat = 1.0,
        includeAlpha: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Clamp",
            shader: .name("clamp"),
            graphics: [self],
            uniforms: ClampUniforms(
                includeAlpha: includeAlpha,
                type: type.index,
                low: Float(low),
                high: Float(high)
            ),
            options: options.renderOptions
        )
    }
}
