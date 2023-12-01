//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import PixelColor

extension Graphic3D {
    
    private struct Slope3DUniforms {
        let amplitude: Float
        let origin: ColorUniform
    }
    
    public func slope(amplitude: CGFloat = 100,
                      origin: PixelColor = .rawGray,
                      options: EffectOptions = []) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Slope 3D",
            shader: .name("slope3d"),
            graphics: [self],
            uniforms: Slope3DUniforms(
                amplitude: Float(amplitude),
                origin: origin.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
