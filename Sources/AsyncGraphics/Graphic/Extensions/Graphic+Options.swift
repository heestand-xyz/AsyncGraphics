//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap
import Metal
import PixelColor

extension Graphic {
    
    public struct ContentOptions: OptionSet, Hashable {
        
        public let rawValue: Int
        
        /// 16 bit rendering
        public static let bit16 = ContentOptions(rawValue: 1 << 0)
        
        /// 32 bit rendering
        public static let bit32 = ContentOptions(rawValue: 1 << 1)

        var bits: TMBits {
            contains(.bit32) ? ._32 : contains(.bit16) ? ._16 : ._8
        }
        
        public static let pureAlpha = ContentOptions(rawValue: 1 << 2)
        
        var premultiply: Bool {
            !contains(.pureAlpha)
        }
       
        /// Display P3 Color Space
        public static let displayP3 = ContentOptions(rawValue: 1 << 3)
        
        var colorSpace: TMColorSpace {
            contains(.displayP3) ? .displayP3 : .sRGB
        }
        
        public static let pixelated = ContentOptions(rawValue: 1 << 4)
        
        var antiAlias: Bool {
            !contains(.pixelated)
        }

        public static let interpolateNearest: ContentOptions = .pixelated
        
        /// If the background color is clear, it will be modified to include the foreground color when anti aliased.
        public static let pureTranslucentColor = ContentOptions(rawValue: 1 << 5)

        func pureTranslucentBackgroundColor(_ backgroundColor: PixelColor, color: PixelColor) -> PixelColor {
            if contains(.pureTranslucentColor) {
                if backgroundColor.alpha == 0.0 {
                    return color.withAlpha(of: 0.0)
                }
            }
            return backgroundColor
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
        
        /// Edge sampling method of loop
        ///
        /// Pixels sampled outside of uv coordinates 0.0 and 1.0 will be repeated
        public static let edgeLoop = EffectOptions(rawValue: 1 << 2)

        var addressMode: MTLSamplerAddressMode {
            contains(.edgeLoop) ? .repeat : contains(.edgeMirror) ? .mirrorRepeat : contains(.edgeStretch) ? .clampToEdge : .clampToZero
        }
        
        public static let pureAlpha = EffectOptions(rawValue: 1 << 3)
        
        var premultiply: Bool {
            !contains(.pureAlpha)
        }
        
        public static let interpolateNearest = EffectOptions(rawValue: 1 << 4)

        var filter: MTLSamplerMinMagFilter {
            contains(.interpolateNearest) ? .nearest : .linear
        }
        
        /// Use this when assigning the modified ``Graphic`` to the source ``Graphic``, when replacing the original ``Graphic`` with the new.
        ///
        /// This option can render `2x` faster.
        public static let replace = EffectOptions(rawValue: 1 << 5)

        var renderOptions: Renderer.Options {
            Renderer.Options(
                addressMode: addressMode,
                filter: filter,
                targetSourceTexture: contains(.replace)
            )
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
