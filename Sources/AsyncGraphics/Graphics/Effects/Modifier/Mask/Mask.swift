//
//  Created by Anton Heestand on 2022-04-03.
//

import Metal
import SwiftUI
import CoreGraphicsExtensions

extension Graphic {
    
    public static func mask(
        foreground foregroundGraphic: Graphic,
        background backgroundGraphic: Graphic,
        mask maskGraphic: Graphic,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let alphaGraphic = try await maskGraphic.luminanceToAlpha()
        
        let graphic = try await alphaGraphic.blended(with: foregroundGraphic, blendingMode: .multiply, placement: placement)
        
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over, placement: placement)
    }
}
