//
//  Created by Anton Heestand on 2022-04-02.
//

import Metal
import TextureMap

extension Graphic {
    
    @EnumMacro
    public enum Bits: String, GraphicEnum {
        case bit8
        case bit16
        case bit32
        public init(tmBits: TMBits) {
            switch tmBits {
            case ._8: self = .bit8
            case ._16: self = .bit16
            case ._32: self = .bit32
            }
        }
        public var tmBits: TMBits {
            switch self {
            case .bit8: ._8
            case .bit16: ._16
            case .bit32: ._32
            }
        }
    }

    @available(*, deprecated, renamed: "withBits(_:)")
    public func bits(_ tmBits: TMBits) async throws -> Graphic {
        try await withBits(Bits(tmBits: tmBits))
    }
    
    /// 8, 16 or 32 bits
    ///
    /// **8 bits** is default when working with images.
    ///
    /// **16 bits** has colors beyond black and white with more precision.
    ///
    /// **32 bits** has the most amount of precision.
    public func withBits(_ bits: Bits) async throws -> Graphic {
        
        if self.bits == bits.tmBits {
            return self
        }
        
        return try await Renderer.render(
            name: "Bits",
            shader: .name("bits"),
            graphics: [self],
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits.tmBits
            )
        )
    }
}
