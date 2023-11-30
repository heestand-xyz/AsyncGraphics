//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct ColorMapUniforms {
        let backgroundColor: ColorUniform
        let foregroundColor: ColorUniform
    }
    
    public func colorMap(from backgroundColor: PixelColor,
                         to foregroundColor: PixelColor,
                         options: EffectOptions = []) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Color Map",
            shader: .name("colorMap"),
            graphics: [self],
            uniforms: ColorMapUniforms(
                backgroundColor: backgroundColor.uniform,
                foregroundColor: foregroundColor.uniform),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
