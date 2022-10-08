//
//  Created by Anton Heestand on 2022-04-03.
//

import Metal

extension Graphic {
    
    private struct BlendUniforms {
        let blendingMode: Int32
        let placement: Int32
    }
    
    public func blended(
        with graphic: Graphic,
        blendingMode: BlendingMode,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blend",
            shader: .name("blend"),
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                blendingMode: Int32(blendingMode.index),
                placement: Int32(placement.index)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
    
    public static func mask(
        foreground foregroundGraphic: Graphic,
        background backgroundGraphic: Graphic,
        mask maskGraphic: Graphic,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        let alphaGraphic = try await maskGraphic.luminanceToAlpha()
        let graphic = try await foregroundGraphic.blended(with: alphaGraphic, blendingMode: .multiply, placement: placement)
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over, placement: placement)
    }
}
