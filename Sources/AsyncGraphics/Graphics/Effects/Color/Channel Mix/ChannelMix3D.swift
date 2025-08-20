//
//  Created by Anton Heestand on 2022-05-04.
//

import PixelColor

extension Graphic3D {
    
    private struct ChannelMix3DUniforms: Uniforms {
        let red: ColorUniform
        let green: ColorUniform
        let blue: ColorUniform
        let alpha: ColorUniform
        let white: ColorUniform
        let mono: ColorUniform
    }
    
    public func channelMix(
        red: Graphic.ColorChannel = .red,
        green: Graphic.ColorChannel = .green,
        blue: Graphic.ColorChannel = .blue,
        alpha: Graphic.ColorChannel = .alpha,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
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
                    red: red == .one ? 1.0 : 0.0,
                    green: green == .one ? 1.0 : 0.0,
                    blue: blue == .one ? 1.0 : 0.0,
                    alpha: alpha == .one ? 1.0 : 0.0
                ),
                mono: ColorUniform(
                    red: red == .luminance ? 1.0 : 0.0,
                    green: green == .luminance ? 1.0 : 0.0,
                    blue: blue == .luminance ? 1.0 : 0.0,
                    alpha: alpha == .luminance ? 1.0 : 0.0
                )
            ),
            options: options.colorRenderOptions
        )
    }
}

extension Graphic3D {
    
    public func alphaToLuminance() async throws -> Graphic3D {
        try await channelMix(red: .alpha, green: .alpha, blue: .alpha, alpha: .one)
    }
    
    public func alphaToLuminanceWithAlpha() async throws -> Graphic3D {
        try await channelMix(red: .alpha, green: .alpha, blue: .alpha, alpha: .alpha)
    }
    
    public func luminanceToAlpha() async throws -> Graphic3D {
        try await monochrome().channelMix(red: .luminance, green: .luminance, blue: .luminance, alpha: .luminance)
    }
    
    public func luminanceToAlphaWithColor() async throws -> Graphic3D {
        try await channelMix(red: .red, green: .green, blue: .blue, alpha: .luminance)
    }
}
