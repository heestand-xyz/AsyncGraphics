//
//  Created by Anton Heestand on 2022-04-02.
//

import Metal
import TextureMap

extension Graphic3D {
    
    /// 8 bits
    @available(*, deprecated, renamed: "bits(_:)")
    public func standardBit() async throws -> Graphic3D {
        
        try await bits(._8)
    }
    
    /// 16 bits
    @available(*, deprecated, renamed: "bits(_:)")
    public func highBit() async throws -> Graphic3D {
        
        try await bits(._16)
    }
    
    /// 8, 16 or 32 bits
    ///
    /// **8 bits** is default when working with images.
    ///
    /// **16 bits** has colors beyond black and white with more precision.
    ///
    /// **32 bits** has the most amount of precision.
    public func bits(_ bits: TMBits) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Bits 3D",
            shader: .name("bits3d"),
            graphics: [self],
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}
