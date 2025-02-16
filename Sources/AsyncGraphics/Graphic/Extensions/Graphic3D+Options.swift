//
//  Created by Anton Heestand on 2022-04-21.
//

import TextureMap
import Metal
import PixelColor

extension Graphic3D {
    
    public struct ContentOptions: OptionSet, Hashable, Sendable {
        
        public let rawValue: Int
        
        /// 16 bit rendering
        public static let bit16 = ContentOptions(rawValue: 1 << 0)
        
        /// 32 bit rendering
        public static let bit32 = ContentOptions(rawValue: 1 << 1)

        var bits: TMBits {
            contains(.bit32) ? ._32 : contains(.bit16) ? ._16 : ._8
        }
        
        /// Display P3 Color Space
//        public static let displayP3 = ContentOptions(rawValue: 1 << 1)
        
        public static let pureAlpha = ContentOptions(rawValue: 1 << 2)
                
        var premultiply: Bool {
            !contains(.pureAlpha)
        }
        
        var colorSpace: TMColorSpace {
            .sRGB //contains(.displayP3) ? .displayP3 : .sRGB
        }
        
        public static let pixelated = ContentOptions(rawValue: 1 << 3)
        
        /// If the background color is clear, it will be modified to include the foreground color when anti aliased.
        public static let pureTranslucentColor = ContentOptions(rawValue: 1 << 4)

        func pureTranslucentBackgroundColor(_ backgroundColor: PixelColor, color: PixelColor) -> PixelColor {
            if contains(.pureTranslucentColor) {
                if backgroundColor.opacity == 0.0 {
                    return color.withOpacity(of: 0.0)
                }
            }
            return backgroundColor
        }
        
        var antiAlias: Bool {
            !contains(.pixelated)
        }
       
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct EffectOptions: OptionSet, Hashable, Sendable {
        
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
        /// Pixels sampled outside of uv coordinates 0.0 and 1.0 will be looped
        public static let edgeLoop = EffectOptions(rawValue: 1 << 2)
        
        var addressMode: MTLSamplerAddressMode {
            contains(.edgeMirror) ? .mirrorRepeat : contains(.edgeLoop) ? .repeat : contains(.edgeStretch) ? .clampToEdge : .clampToZero
        }
        
        /// Use this when assigning the modified ``Graphic`` to the source ``Graphic``, when replacing the original ``Graphic`` with the new.
        ///
        /// This option can render `2x` faster.
        /// 
        /// This option can only be used on color effects, not distortion effects.
        /// Please don't use this option if the effect changes the resolution. 
        public static let replace = EffectOptions(rawValue: 1 << 3)

        var colorRenderOptions: Renderer.Options {
            Renderer.Options(
                targetSourceTexture: contains(.replace)
            )
        }
        
        var spatialRenderOptions: Renderer.Options {
            Renderer.Options(
                addressMode: addressMode
            )
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
