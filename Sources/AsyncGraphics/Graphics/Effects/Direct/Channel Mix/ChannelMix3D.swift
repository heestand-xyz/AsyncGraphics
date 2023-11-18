//
//  Created by Anton Heestand on 2022-05-04.
//

import PixelColor

extension Graphic3D {
    
    private struct ChannelMix3DUniforms {
        let red: ColorUniform
        let green: ColorUniform
        let blue: ColorUniform
        let alpha: ColorUniform
        let white: ColorUniform
        let mono: ColorUniform
    }
    
    public func channelMix(red: Graphic.ColorChannel = .red,
                           green: Graphic.ColorChannel = .green,
                           blue: Graphic.ColorChannel = .blue,
                           alpha: Graphic.ColorChannel = .alpha) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Channel Mix 3D",
            shader: .name("channelMix3d"),
            graphics: [self],
            uniforms: ChannelMix3DUniforms(
                red: red.color.uniform,
                green: green.color.uniform,
                blue: blue.color.uniform,
                alpha: alpha.color.uniform,
                white: ColorUniform(
                    red: red == .white ? 1.0 : 0.0,
                    green: green == .white ? 1.0 : 0.0,
                    blue: blue == .white ? 1.0 : 0.0,
                    alpha: alpha == .white ? 1.0 : 0.0
                ),
                mono: ColorUniform(
                    red: red == .mono ? 1.0 : 0.0,
                    green: green == .mono ? 1.0 : 0.0,
                    blue: blue == .mono ? 1.0 : 0.0,
                    alpha: alpha == .mono ? 1.0 : 0.0
                )
            )
        )
    }
}

extension Graphic3D {
    
    public func alphaToLuminance() async throws -> Graphic3D {
        try await channelMix(red: .alpha, green: .alpha, blue: .alpha, alpha: .white)
    }
    
    public func alphaToLuminanceWithAlpha() async throws -> Graphic3D {
        try await channelMix(red: .alpha, green: .alpha, blue: .alpha, alpha: .alpha)
    }
    
    public func luminanceToAlpha() async throws -> Graphic3D {
        try await monochrome().channelMix(red: .mono, green: .mono, blue: .mono, alpha: .mono)
    }
}
