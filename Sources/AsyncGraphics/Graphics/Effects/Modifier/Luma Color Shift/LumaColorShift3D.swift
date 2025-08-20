//
//  Created by Anton Heestand on 2022-09-12.
//

import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension Graphic3D {
    
    private struct LumaColorShift3DUniforms: Uniforms {
        let placement: UInt32
        let hue: Float
        let saturation: Float
        let tintColor: ColorUniform
        let lumaGamma: Float
    }
    
    public func lumaMonochrome(
        with graphic: Graphic3D,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaColorShifted(
            with: graphic,
            saturation: 0.0,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    /// `1.0` is *default*
    public func lumaSaturated(
        with graphic: Graphic3D,
        saturation: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
    
        try await lumaColorShifted(
            with: graphic,
            saturation: saturation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    /// `0.0` is *default*, `0.5` is `180` degrees of hue shift
    public func lumaHue(
        with graphic: Graphic3D,
        hue: Angle,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
    
        try await lumaColorShifted(
            with: graphic,
            hue: hue,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaTinted(
        with graphic: Graphic3D,
        color: PixelColor,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
    
        try await lumaColorShifted(
            with: graphic,
            tintColor: color,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    func lumaColorShifted(
        with graphic: Graphic3D,
        hue: Angle = .zero,
        saturation: CGFloat = 1.0,
        tintColor: PixelColor = .white,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Luma Color Shift 3D",
            shader: .name("lumaColorShift3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaColorShift3DUniforms(
                placement: placement.index,
                hue: hue.uniform,
                saturation: Float(saturation),
                tintColor: tintColor.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: options.colorRenderOptions
        )
    }
}
