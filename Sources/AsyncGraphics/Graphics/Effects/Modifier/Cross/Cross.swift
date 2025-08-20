//
//  Created by Anton Heestand on 2022-04-19.
//

import CoreGraphics

extension Graphic {
    
    private struct CrossUniforms: Uniforms {
        let fraction: Float
        let placement: Int32
    }
    
    public func cross(
        with graphic: Graphic,
        fraction: CGFloat,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Cross",
            shader: .name("cross"),
            graphics: [
                self,
                graphic
            ],
            uniforms: CrossUniforms(
                fraction: Float(fraction),
                placement: Int32(placement.index)
            ),
            options: options.colorRenderOptions
        )
    }
}
