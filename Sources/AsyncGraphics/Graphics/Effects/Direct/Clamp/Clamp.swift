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
    
    public enum ClampType: String, Codable, Identifiable, CaseIterable {
        case hold
        case loop
        case mirror
        case zero
        case relative
        public var id: String {
            rawValue
        }
        var index: UInt32 {
            switch self {
            case .hold:
                return 0
            case .loop:
                return 1
            case .mirror:
                return 2
            case .zero:
                return 3
            case .relative:
                return 4
            }
        }
    }
    
    public func clamp(
        _ type: ClampType = .relative,
        low: CGFloat = 0.0,
        high: CGFloat = 1.0,
        includeAlpha: Bool = false,
        options: EffectOptions = EffectOptions()
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
            )
        )
    }
}
