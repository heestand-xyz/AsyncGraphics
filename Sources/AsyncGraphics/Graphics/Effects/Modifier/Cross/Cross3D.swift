//
//  Created by Anton Heestand on 2022-04-28.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Cross3DUniforms: Uniforms {
        let fraction: Float
        let placement: Int32
    }
    
    public func cross(
        with graphic: Graphic3D,
        fraction: CGFloat,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Cross 3D",
            shader: .name("cross3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: Cross3DUniforms(
                fraction: Float(fraction),
                placement: Int32(placement.index)
            ),
            options: options.colorRenderOptions
        )
    }
}
