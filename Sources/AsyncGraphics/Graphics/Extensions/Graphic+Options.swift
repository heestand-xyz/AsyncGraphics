//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap
import Metal

extension Graphic {
    
    public struct ContentOptions: OptionSet {
        
        public let rawValue: Int
        
        @available(*, deprecated, renamed: "bit16")
        public static let highBit: ContentOptions = .bit16
        
        /// 16 bit rendering
        public static let bit16 = ContentOptions(rawValue: 1 << 0)
        
        /// 32 bit rendering
        public static let bit32 = ContentOptions(rawValue: 1 << 1)

        var bits: TMBits {
            contains(.bit32) ? ._32 : contains(.bit16) ? ._16 : ._8
        }
        
        /// Display P3 Color Space
//        public static let displayP3 = ContentOptions(rawValue: 1 << 2)
        
        var colorSpace: TMColorSpace {
            .sRGB //contains(.displayP3) ? .displayP3 : .sRGB
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct EffectOptions: OptionSet {
        
        public let rawValue: Int
        
        /// Edge sampling method of mirror
        ///
        /// Pixels sampled outside of uv coordinates 0.0 and 1.0 will be mirrored
        public static let edgeMirror = EffectOptions(rawValue: 1 << 0)
        
        /// Edge sampling method of stretch
        ///
        /// Pixels sampled outside of uv coordinates 0.0 and 1.0 will be stretched
        public static let edgeStretch = EffectOptions(rawValue: 1 << 1)

        var addressMode: MTLSamplerAddressMode {
            contains(.edgeMirror) ? .mirrorRepeat : contains(.edgeStretch) ? .clampToEdge : .clampToZero
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
