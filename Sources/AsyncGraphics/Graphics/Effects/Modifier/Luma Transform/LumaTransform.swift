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
    
    public func lumaOffset(
        with graphic: Graphic,
        translation: CGPoint,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            with: graphic,
            translation: translation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaOffset(
        with graphic: Graphic,
        x: CGFloat = 0.0,
        y: CGFloat = 0.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            with: graphic,
            translation: CGPoint(x: x, y: y),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaRotated(
        with graphic: Graphic,
        rotation: Angle,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            with: graphic,
            rotation: rotation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaScaled(
        with graphic: Graphic,
        scale: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            with: graphic,
            scale: scale,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaScaled(
        with graphic: Graphic,
        x: CGFloat = 1.0,
        y: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaTransformed(
            with: graphic,
            scaleSize: CGSize(width: x, height: y),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    func lumaTransformed(
        with graphic: Graphic,
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        scaleSize: CGSize = .one,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let relativeTranslation: CGPoint = translation / resolution.height
        
        return try await Renderer.render(
            name: "Luma Transform",
            shader: .name("lumaTransform"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaTransformUniforms(
                placement: placement.index,
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: scaleSize.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: options.renderOptions
        )
    }
}
