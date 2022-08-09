//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics

extension Graphic {
    
    private struct SlopeUniforms {
        let amplitude: Float
    }
    
    public func slope(amplitude: CGFloat = 100,
                      options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Slope",
            shader: .name("slope"),
            graphics: [self],
            uniforms: SlopeUniforms(
                amplitude: Float(amplitude)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
