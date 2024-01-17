//
//  Created by Anton Heestand on 2022-09-12.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI
import TextureMap

extension Graphic {
    
    private struct LumaRainbowBlurUniforms {
        let type: UInt32
        let placement: UInt32
        let count: UInt32
        let radius: Float
        let angle: Float
        let light: Float
        let lumaGamma: Float
        let position: PointUniform
    }
    
    @EnumMacro
    public enum LumaRainbowBlurType: String, GraphicEnum {
        case circle
        case angle
        case zoom
    }
    
    public func lumaRainbowBlurredCircle(
        with graphic: Graphic,
        radius: CGFloat,
        angle: Angle = .zero,
        light: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaRainbowBlurred(
            with: graphic,
            type: .circle,
            radius: radius,
            angle: angle,
            light: light,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaRainbowBlurredZoom(
        with graphic: Graphic,
        radius: CGFloat,
        position: CGPoint? = nil,
        light: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaRainbowBlurred(
            with: graphic,
            type: .zoom,
            radius: radius,
            position: position,
            light: light,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaRainbowBlurredAngle(
        with graphic: Graphic,
        radius: CGFloat,
        angle: Angle,
        light: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
    
        try await lumaRainbowBlurred(
            with: graphic,
            type: .angle,
            radius: radius,
            angle: angle,
            light: light,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    func lumaRainbowBlurred(
        with graphic: Graphic,
        type: LumaRainbowBlurType,
        radius: CGFloat,
        position: CGPoint? = nil,
        angle: Angle = .zero,
        light: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let position: CGPoint = position ?? resolution.asPoint / 2
        let relativePosition: CGPoint = (position - resolution / 2) / height
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Luma Rainbow Blur",
            shader: .name("lumaRainbowBlur"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaRainbowBlurUniforms(
                type: type.index,
                placement: placement.index,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                angle: angle.uniform,
                light: Float(light),
                lumaGamma: Float(lumaGamma),
                position: relativePosition.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}

