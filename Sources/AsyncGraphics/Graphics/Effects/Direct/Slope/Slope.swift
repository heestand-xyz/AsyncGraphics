//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct SlopeUniforms {
        let amplitude: Float
        let origin: ColorUniform
    }
    
    public func slope(amplitude: CGFloat = 100,
                      origin: PixelColor = .gray,
                      options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Slope",
            shader: .name("slope"),
            graphics: [self],
            uniforms: SlopeUniforms(
                amplitude: Float(amplitude),
                origin: origin.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
