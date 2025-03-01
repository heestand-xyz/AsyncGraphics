//
//  Created by Anton Heestand on 2022-05-04.
//

import PixelColor

extension Graphic {
    
    private struct ChannelMixUniforms {
        let red: ColorUniform
        let green: ColorUniform
        let blue: ColorUniform
        let alpha: ColorUniform
        let isOne: ColorUniform
        let isLuma: ColorUniform
    }
    
    @EnumMacro
    public enum ColorChannel: String, GraphicEnum {
        
        case red
        case green
        case blue
        case alpha
        case zero
        case one
        case luma
        @available(*, deprecated, renamed: "zero")
        case clear
        @available(*, deprecated, renamed: "one")
        case white
        @available(*, deprecated, renamed: "luminance")
        case mono
        
        public static var allCases: [Graphic.ColorChannel] {
            [.red, .green, .blue, .alpha, .zero, .one, .luma]
        }
            
        public var color: PixelColor {
            switch self {
            case .red:
                return PixelColor(channel: .red)
            case .green:
                return PixelColor(channel: .green)
            case .blue:
                return PixelColor(channel: .blue)
            case .alpha:
                return PixelColor(channel: .alpha)
            default:
                return .clear
            }
        }
    }
    
    public func channelMix(
        red: ColorChannel = .red,
        green: ColorChannel = .green,
        blue: ColorChannel = .blue,
        alpha: ColorChannel = .alpha,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Channel Mix",
            shader: .name("channelMix"),
            graphics: [self],
            uniforms: ChannelMixUniforms(
                red: red.color.uniform,
                green: green.color.uniform,
                blue: blue.color.uniform,
                alpha: alpha.color.uniform,
                isOne: ColorUniform(
                    red: red == .one ? 1.0 : 0.0,
                    green: green == .one ? 1.0 : 0.0,
                    blue: blue == .one ? 1.0 : 0.0,
                    alpha: alpha == .one ? 1.0 : 0.0
                ),
                isLuma: ColorUniform(
                    red: red == .luma ? 1.0 : 0.0,
                    green: green == .luma ? 1.0 : 0.0,
                    blue: blue == .luma ? 1.0 : 0.0,
                    alpha: alpha == .luma ? 1.0 : 0.0
                )
            ),
            options: options.colorRenderOptions
        )
    }
}

extension Graphic {
    
    public func alphaToLuminance() async throws -> Graphic {
        try await channelMix(red: .alpha, green: .alpha, blue: .alpha, alpha: .one)
    }
    
    public func alphaToLuminanceWithAlpha() async throws -> Graphic {
        try await channelMix(red: .alpha, green: .alpha, blue: .alpha, alpha: .alpha)
    }
    
    public func luminanceToAlpha() async throws -> Graphic {
        try await monochrome().channelMix(red: .luma, green: .luma, blue: .luma, alpha: .luma)
    }
    
    public func luminanceToAlphaWithColor() async throws -> Graphic {
        try await channelMix(red: .red, green: .green, blue: .blue, alpha: .luma)
    }
}
