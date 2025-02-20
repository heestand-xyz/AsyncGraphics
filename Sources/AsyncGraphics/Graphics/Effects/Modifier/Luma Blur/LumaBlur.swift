//
//  Created by Anton Heestand on 2022-09-10.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    private struct LumaBlurUniforms {
        let type: UInt32
        let placement: UInt32
        let count: UInt32
        let radius: Float
        let position: PointUniform
        let angle: Float
        let lumaGamma: Float
    }
   
    @EnumMacro
    public enum LumaBlurType: String, GraphicEnum {
        case box
        case angle
        case zoom
        case random
        case layered
    }
    
    public func lumaBlurredLayered(
        with graphic: Graphic,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        layerCount: Int = 10,
        placement: Placement = .fit,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        if layerCount < 1 { return self }
        var blurredGraphic: Graphic = self
        var radius: CGFloat = radius
        for _ in 0..<layerCount {
            blurredGraphic = try await blurredGraphic.lumaBlurredLayeredSinglePass(
                with: graphic,
                radius: radius,
                lumaGamma: lumaGamma,
                placement: placement,
                options: options
            )
            radius /= 2.0
        }
        return blurredGraphic
    }
    
    public func lumaBlurredLayeredSinglePass(
        with graphic: Graphic,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            with: graphic,
            type: .layered,
            radius: radius,
            lumaGamma: lumaGamma,
            sampleCount: 1,
            placement: placement,
            options: options
        )
    }
    
    public func lumaBlurredBox(
        with graphic: Graphic,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            with: graphic,
            type: .box,
            radius: radius,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
 
    public func lumaBlurredZoom(
        with graphic: Graphic,
        radius: CGFloat,
        position: CGPoint? = nil,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            with: graphic,
            type: .zoom,
            radius: radius,
            position: position,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaBlurredAngle(
        with graphic: Graphic,
        radius: CGFloat,
        angle: Angle,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            with: graphic,
            type: .angle,
            radius: radius,
            angle: angle,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaBlurredRandom(
        with graphic: Graphic,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            with: graphic,
            type: .random,
            radius: radius,
            options: options
        )
    }
    
    func lumaBlurred(
        with graphic: Graphic,
        type: LumaBlurType,
        radius: CGFloat,
        position: CGPoint? = nil,
        angle: Angle = .zero,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
            
        let relativeRadius: CGFloat = radius / height
       
        let position: CGPoint = position ?? resolution.asPoint / 2
        let relativePosition: CGPoint = (position - resolution / 2) / height
        
        return try await Renderer.render(
            name: "Luma Blur",
            shader: .name("lumaBlur"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaBlurUniforms(
                type: type.index,
                placement: placement.index,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                angle: angle.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: options.spatialRenderOptions
        )
    }
}
