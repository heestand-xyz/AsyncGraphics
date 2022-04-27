//
//  Created by Anton Heestand on 2022-04-12.
//

extension Graphic {
    
    private struct BlendsUniforms {
        let mode: Int
    }
    
    public static func blend(with graphics: [Graphic],
                             blendingMode: ArrayBlendingMode,
                             options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blends",
            shader: .name("blends"),
            graphics: graphics,
            uniforms: BlendsUniforms(
                mode: blendingMode.index
            ),
            options: Renderer.Options(
                isArray: true,
                addressMode: options.addressMode
            )
        )
    }
}


extension Array where Element == Graphic {
    
    public func blended(blendingMode: ArrayBlendingMode,
                        options: Graphic.EffectOptions = Graphic.EffectOptions()) async throws -> Graphic {
        
        try await Graphic.blend(with: self,
                                blendingMode: blendingMode,
                                options: options)
    }
}
