//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap
import Metal

extension Graphic3D {
    
    public struct ContentOptions: OptionSet {
        
        public let rawValue: Int
        
        /// 16 bit rendering
        public static let highBit = ContentOptions(rawValue: 1 << 0)
        
        var bits: TMBits {
            contains(.highBit) ? ._16 : ._8
        }
        
        /// Display P3 Color Space
        public static let displayP3 = ContentOptions(rawValue: 1 << 1)
        
        var colorSpace: TMColorSpace {
            contains(.displayP3) ? .displayP3 : .sRGB
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct EffectOptions: OptionSet {
        
        public let rawValue: Int
        
        public static let edgeMirror = EffectOptions(rawValue: 1 << 0)
        public static let edgeStretch = EffectOptions(rawValue: 1 << 1)
        
        var addressMode: MTLSamplerAddressMode {
            contains(.edgeMirror) ? .mirrorRepeat : contains(.edgeStretch) ? .clampToEdge : .clampToZero
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
