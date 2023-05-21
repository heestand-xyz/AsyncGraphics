//
//  Created by Anton Heestand on 2022-09-12.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    private struct LumaTransformUniforms {
        let placement: UInt32
        let translation: PointUniform
        let rotation: Float
        let scale: Float
        let size: SizeUniform
        let lumaGamma: Float
    }
    
    @available(*, deprecated, renamed: "lumaOffset(_:lumaGamma:placement:options:graphic:)")
    public func lumaTranslated(
        with graphic: Graphic,
        translation: CGPoint,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            translation: translation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    public func lumaOffset(
        _ translation: CGPoint,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions(),
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            translation: translation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
    
    @available(*, deprecated, renamed: "lumaOffset(x:y:lumaGamma:placement:options:graphic:)")
    public func lumaTranslated(
        with graphic: Graphic,
        x: CGFloat = 0.0,
        y: CGFloat = 0.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            translation: CGPoint(x: x, y: y),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    public func lumaOffset(
        x: CGFloat = 0.0,
        y: CGFloat = 0.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions(),
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            translation: CGPoint(x: x, y: y),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
    
    @available(*, deprecated, renamed: "lumaRotated(rotation:lumaGamma:placement:options:graphic:)")
    public func lumaRotated(
        with graphic: Graphic,
        rotation: Angle,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            rotation: rotation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    public func lumaRotated(
        rotation: Angle,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions(),
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            rotation: rotation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
    
    @available(*, deprecated, renamed: "lumaScaled(scale:lumaGamma:placement:options:graphic:)")
    public func lumaScaled(
        with graphic: Graphic,
        scale: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            scale: scale,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    public func lumaScaled(
        scale: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions(),
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            scale: scale,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
    
    @available(*, deprecated, renamed: "lumaScaled(x:y:lumaGamma:placement:options:graphic:)")
    public func lumaScaled(
        with graphic: Graphic,
        x: CGFloat = 1.0,
        y: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            scaleSize: CGSize(width: x, height: y),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    public func lumaScaled(
        x: CGFloat = 1.0,
        y: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions(),
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            scaleSize: CGSize(width: x, height: y),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
    
    private func lumaTransformed(
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        scaleSize: CGSize = .one,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions(),
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        let relativeTranslation: CGPoint = translation / resolution.height
        
        return try await Renderer.render(
            name: "Luma Transform",
            shader: .name("lumaTransform"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: LumaTransformUniforms(
                placement: placement.index,
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: scaleSize.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
