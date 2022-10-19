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
        let white: ColorUniform
    }
    
    public enum ColorChannel {
        
        case red
        case green
        case blue
        case alpha
        case clear
        case white
        
        var color: PixelColor {
            switch self {
            case .red:
                return PixelColor(channel: .red)
            case .green:
                return PixelColor(channel: .green)
            case .blue:
                return PixelColor(channel: .blue)
            case .alpha:
                return PixelColor(channel: .alpha)
            case .clear:
                return .clear
            case .white:
                return .white
            }
        }
    }
    
    public func channelMix(red: ColorChannel = .red,
                           green: ColorChannel = .green,
                           blue: ColorChannel = .blue,
                           alpha: ColorChannel = .alpha) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Channel Mix",
            shader: .name("channelMix"),
            graphics: [self],
            uniforms: ChannelMixUniforms(
                red: red.color.uniform,
                green: green.color.uniform,
                blue: blue.color.uniform,
                alpha: alpha.color.uniform,
                white: ColorUniform(
                    red: red == .white ? 1.0 : 0.0,
                    green: green == .white ? 1.0 : 0.0,
                    blue: blue == .white ? 1.0 : 0.0,
                    alpha: alpha == .white ? 1.0 : 0.0
                )
            )
        )
    }
}

extension Graphic {
    
    public func alphaToLuminance() async throws -> Graphic {
        try await channelMix(red: .alpha, green: .alpha, blue: .alpha, alpha: .white)
    }
    
    public func luminanceToAlpha() async throws -> Graphic {
        try await monochrome().channelMix(red: .white, green: .white, blue: .white, alpha: .red)
    }
}
