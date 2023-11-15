//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Threshold3DUniforms {
        let fraction: Float
    }
    
    public func threshold(_ fraction: CGFloat = 0.5,
                          options: EffectOptions = []) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Threshold",
            shader: .name("threshold3d"),
            graphics: [self],
            uniforms: Threshold3DUniforms(
                fraction: Float(fraction)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
