//
//  Created by Anton Heestand on 2022-09-12.
//

import SwiftUI
import Spatial

extension Graphic3D {
    
    private struct LumaTransform3DUniforms {
        let placement: UInt32
        let translation: VectorUniform
        let rotation: VectorUniform
        let scale: Float
        let size: VectorUniform
        let lumaGamma: Float
    }
    
    public func lumaOffset(
        with graphic: Graphic3D,
        translation: Point3D,
        lumaGamma: Double = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaTransformed(
            with: graphic,
            translation: translation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaOffset(
        with graphic: Graphic3D,
        x: Double = 0.0,
        y: Double = 0.0,
        z: Double = 0.0,
        lumaGamma: Double = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaTransformed(
            with: graphic,
            translation: Point3D(x: x, y: y, z: z),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaRotated(
        with graphic: Graphic3D,
        rotation: Point3D,
        lumaGamma: Double = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaTransformed(
            with: graphic,
            rotation: rotation,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaScaled(
        with graphic: Graphic3D,
        scale: Double,
        lumaGamma: Double = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaTransformed(
            with: graphic,
            scale: scale,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaScaled(
        with graphic: Graphic3D,
        x: Double = 1.0,
        y: Double = 1.0,
        z: Double = 1.0,
        lumaGamma: Double = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaTransformed(
            with: graphic,
            scaleSize: Size3D(width: x, height: y, depth: z),
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    func lumaTransformed(
        with graphic: Graphic3D,
        translation: Point3D = .zero,
        rotation: Point3D = .zero,
        scale: Double = 1.0,
        scaleSize: Size3D = .one,
        lumaGamma: Double = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let relativeTranslation: Point3D = translation / Double(height)
        
        return try await Renderer.render(
            name: "Luma Transform 3D",
            shader: .name("lumaTransform3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaTransform3DUniforms(
                placement: placement.index,
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: scaleSize.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: options.spatialRenderOptions
        )
    }
}
