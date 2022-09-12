//
//  Created by Anton Heestand on 2022-09-12.
//

import SwiftUI
import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct LumaColorShiftUniforms {
        let placement: UInt32
        let hue: Float
        let saturation: Float
        let tintColor: ColorUniform
        let gamma: Float
    }
    
    public func lumaMonochrome(with graphic: Graphic) async throws -> Graphic {
        try await lumaColorShifted(with: graphic, saturation: 0.0)
    }
    
    /// `1.0` is *default*
    public func lumaSaturated(with graphic: Graphic, saturation: CGFloat) async throws -> Graphic {
        try await lumaColorShifted(with: graphic, saturation: saturation)
    }
    
    /// `0.0` is *default*, `0.5` is `180` degrees of hue shift
    public func lumaHue(with graphic: Graphic, hue: Angle) async throws -> Graphic {
        try await lumaColorShifted(with: graphic, hue: hue)
    }
    
    public func lumaTinted(with graphic: Graphic, color: PixelColor) async throws -> Graphic {
        try await lumaColorShifted(with: graphic, tintColor: color)
    }
    
    private func lumaColorShifted(
        with graphic: Graphic,
        hue: Angle = .zero,
        saturation: CGFloat = 1.0,
        tintColor: PixelColor = .white,
        gamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Luma Color Shift",
            shader: .name("lumaColorShift"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaColorShiftUniforms(
                placement: placement.index,
                hue: hue.uniform,
                saturation: Float(saturation),
                tintColor: tintColor.uniform,
                gamma: Float(gamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
