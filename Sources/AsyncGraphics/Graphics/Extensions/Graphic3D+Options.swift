//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap
import Metal

extension Graphic3D {
    
    public struct ContentOptions: OptionSet, Hashable {
        
        public let rawValue: Int
        
        /// 16 bit rendering
        public static let highBit = ContentOptions(rawValue: 1 << 0)
        
        var bits: TMBits {
            contains(.highBit) ? ._16 : ._8
        }
        
        /// Display P3 Color Space
//        public static let displayP3 = ContentOptions(rawValue: 1 << 1)
        
        public static let pureAlpha = ContentOptions(rawValue: 1 << 1)
        
        var premultiply: Bool {
            !contains(.pureAlpha)
        }
        
        var colorSpace: TMColorSpace {
            .sRGB //contains(.displayP3) ? .displayP3 : .sRGB
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct EffectOptions: OptionSet, Hashable {
        
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
