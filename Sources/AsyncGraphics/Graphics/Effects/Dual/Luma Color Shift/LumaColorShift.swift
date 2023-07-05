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
        let lumaGamma: Float
    }
    
//    @available(*, deprecated, renamed: "lumaMonochrome(lumaGamma:graphic:)")
    public func lumaMonochrome(
        with graphic: Graphic,
        lumaGamma: CGFloat = 1.0
    ) async throws -> Graphic {
        
        try await lumaColorShifted(
            saturation: 0.0,
            lumaGamma: lumaGamma,
            graphic: { graphic }
        )
    }
    
    public func lumaMonochrome(
        lumaGamma: CGFloat = 1.0,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaColorShifted(
            saturation: 0.0,
            lumaGamma: lumaGamma,
            graphic: graphic
        )
    }
    
//    @available(*, deprecated, renamed: "lumaSaturated(saturation:lumaGamma:graphic:)")
    /// `1.0` is *default*
    public func lumaSaturated(
        with graphic: Graphic,
        saturation: CGFloat,
        lumaGamma: CGFloat = 1.0
    ) async throws -> Graphic {
    
        try await lumaColorShifted(
            saturation: saturation,
            lumaGamma: lumaGamma,
            graphic: { graphic }
        )
    }
    
    /// `1.0` is *default*
    public func lumaSaturated(
        saturation: CGFloat,
        lumaGamma: CGFloat = 1.0,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
    
        try await lumaColorShifted(
            saturation: saturation,
            lumaGamma: lumaGamma,
            graphic: graphic
        )
    }
    
//    @available(*, deprecated, renamed: "lumaHue(hue:lumaGamma:graphic:)")
    /// `0.0` is *default*, `0.5` is `180` degrees of hue shift
    public func lumaHue(
        with graphic: Graphic,
        hue: Angle,
        lumaGamma: CGFloat = 1.0
    ) async throws -> Graphic {
    
        try await lumaColorShifted(
            hue: hue,
            lumaGamma: lumaGamma,
            graphic: { graphic }
        )
    }
    /// `0.0` is *default*, `0.5` is `180` degrees of hue shift
    public func lumaHue(
        hue: Angle,
        lumaGamma: CGFloat = 1.0,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
    
        try await lumaColorShifted(
            hue: hue,
            lumaGamma: lumaGamma,
            graphic: graphic
        )
    }
    
//    @available(*, deprecated, renamed: "lumaTinted(color:lumaGamma:graphic:)")
    public func lumaTinted(
        with graphic: Graphic,
        color: PixelColor,
        lumaGamma: CGFloat = 1.0
    ) async throws -> Graphic {
    
        try await lumaColorShifted(
            tintColor: color,
            lumaGamma: lumaGamma,
            graphic: { graphic }
        )
    }
    
    public func lumaTinted(
        color: PixelColor,
        lumaGamma: CGFloat = 1.0,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
    
        try await lumaColorShifted(
            tintColor: color,
            lumaGamma: lumaGamma,
            graphic: graphic
        )
    }
    
    private func lumaColorShifted(
        hue: Angle = .zero,
        saturation: CGFloat = 1.0,
        tintColor: PixelColor = .white,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Luma Color Shift",
            shader: .name("lumaColorShift"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: LumaColorShiftUniforms(
                placement: placement.index,
                hue: hue.uniform,
                saturation: Float(saturation),
                tintColor: tintColor.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
