//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic {
    
    private struct RemapUniforms {
        var thing: Bool = false
    }
    
    @available(*, deprecated, renamed: "remap(with:options:)")
    public func remap(options: EffectOptions = [],
                      graphic: () async throws -> Graphic) async throws -> Graphic {
        try await remap(with: graphic(), options: options)
    }
    
    public func remap(with graphic: Graphic,
                      options: EffectOptions = []) async throws -> Graphic {        
        try await Renderer.render(
            name: "Remap",
            shader: .name("remap"),
            graphics: [
                graphic,
                self
            ],
            uniforms: RemapUniforms(),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
