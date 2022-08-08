//
//  Created by Anton Heestand on 2022-04-02.
//

import Metal
import TextureMap

extension Graphic {
    
    /// 8 bits
    @available(*, deprecated, renamed: "bits(_:)")
    public func standardBit() async throws -> Graphic {
        
        try await bits(._8)
    }
    
    /// 16 bits
    @available(*, deprecated, renamed: "bits(_:)")
    public func highBit() async throws -> Graphic {
        
        try await bits(._16)
    }
    
    public func bits(_ bits: TMBits) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Bits",
            shader: .name("bits"),
            graphics: [self],
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}
