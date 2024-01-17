//
//  Created by Anton Heestand on 2022-09-12.
//

import SwiftUI
import CoreGraphics
import PixelColor

extension Graphic3D {
    
    private struct LumaLevels3DUniforms {
        let placement: UInt32
        let brightness: Float
        let darkness: Float
        let contrast: Float
        let gamma: Float
        let invert: Bool
        let smooth: Bool
        let opacity: Float
        let offset: Float
        let lumaGamma: Float
    }
   
    /// Default is 1.0
    public func lumaBrightness(
        with graphic: Graphic3D,
        brightness: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            brightness: brightness,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    /// Default is 0.0
    public func lumaDarkness(
        with graphic: Graphic3D,
        darkness: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            darkness: darkness,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    /// Default is 0.0
    public func lumaContrast(
        with graphic: Graphic3D,
        contrast: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            contrast: contrast,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    /// Default is 1.0
    public func lumaGamma(
        with graphic: Graphic3D,
        gamma: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            gamma: gamma,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaInverted(
        with graphic: Graphic3D,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            invert: true,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaSmoothed(
        with graphic: Graphic3D,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            smooth: true,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaOpacity(
        with graphic: Graphic3D,
        opacity: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            opacity: opacity,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    /// Default is 0.0
    public func lumaExposureOffset(
        with graphic: Graphic3D,
        offset: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            offset: offset,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaAdd(
        with graphic: Graphic3D,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            offset: value,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaSubtract(
        with graphic: Graphic3D,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            offset: -value,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaMultiply(
        with graphic: Graphic3D,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            brightness: value,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    public func lumaDivide(
        with graphic: Graphic3D,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaLevels(
            with: graphic,
            brightness: 1.0 / value,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options
        )
    }
    
    func lumaLevels(
        with graphic: Graphic3D,
        brightness: CGFloat = 1.0,
        darkness: CGFloat = 0.0,
        contrast: CGFloat = 0.0,
        gamma: CGFloat = 1.0,
        invert: Bool = false,
        smooth: Bool = false,
        opacity: CGFloat = 1.0,
        offset: CGFloat = 0.0,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Luma Levels 3D",
            shader: .name("lumaLevels3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaLevels3DUniforms(
                placement: placement.index,
                brightness: Float(brightness),
                darkness: Float(darkness),
                contrast: Float(contrast),
                gamma: Float(gamma),
                invert: invert,
                smooth: smooth,
                opacity: Float(opacity),
                offset: Float(offset),
                lumaGamma: Float(lumaGamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
