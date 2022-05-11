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
    }
    
    public enum ColorChannel {
        
        case red
        case green
        case blue
        case alpha
        case clear
        
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
                alpha: alpha.color.uniform
            )
        )
    }
}
