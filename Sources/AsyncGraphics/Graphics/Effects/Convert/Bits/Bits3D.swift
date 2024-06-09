//
//  Created by Anton Heestand on 2022-04-02.
//

import Metal
import TextureMap

extension Graphic3D {
    
    @available(*, deprecated, renamed: "withBits(_:)")
    public func bits(_ tmBits: TMBits) async throws -> Graphic3D {
        try await withBits(Graphic.Bits(tmBits: tmBits))
    }
    
    /// 8, 16 or 32 bits
    ///
    /// **8 bits** is default when working with images.
    ///
    /// **16 bits** has colors beyond black and white with more precision.
    ///
    /// **32 bits** has the most amount of precision.
    public func withBits(
        _ bits: Graphic.Bits,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        if self.bits == bits.tmBits {
            return self
        }
        
        return try await Renderer.render(
            name: "Bits 3D",
            shader: .name("bits3d"),
            graphics: [self],
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits.tmBits
            )
        )
    }
}
