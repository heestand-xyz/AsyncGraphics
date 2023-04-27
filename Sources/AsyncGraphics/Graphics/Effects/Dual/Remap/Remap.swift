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
    
    public func remap(options: EffectOptions = [],
                      graphic: () async throws -> Graphic) async throws -> Graphic {
        
        let graphic: Graphic = try await graphic()
        
        return try await Renderer.render(
            name: "Remap",
            shader: .name("remap"),
            graphics: [
                graphic,
                self
            ],
            uniforms: RemapUniforms(),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
