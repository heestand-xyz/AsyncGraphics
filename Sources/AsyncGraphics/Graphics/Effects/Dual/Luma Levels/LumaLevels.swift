//
//  Created by Anton Heestand on 2022-09-12.
//

import SwiftUI
import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct LumaLevelsUniforms {
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
        with graphic: Graphic,
        brightness: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            brightness: brightness,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    /// Default is 1.0
    @available(*, deprecated, renamed: "lumaBrightness(with:brightness:lumaGamma:placement:)")
    public func lumaBrightness(
        brightness: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            brightness: brightness,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    /// Default is 0.0
    public func lumaDarkness(
        with graphic: Graphic,
        darkness: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            darkness: darkness,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    /// Default is 0.0
    @available(*, deprecated, renamed: "lumaDarkness(with:darkness:lumaGamma:placement:)")
    public func lumaDarkness(
        darkness: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            darkness: darkness,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    /// Default is 0.0
    public func lumaContrast(
        with graphic: Graphic,
        contrast: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            contrast: contrast,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    /// Default is 0.0
    @available(*, deprecated, renamed: "lumaContrast(with:contrast:lumaGamma:placement:)")
    public func lumaContrast(
        contrast: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            contrast: contrast,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    /// Default is 1.0
    public func lumaGamma(
        with graphic: Graphic,
        gamma: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            gamma: gamma,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    /// Default is 1.0
    @available(*, deprecated, renamed: "lumaGamma(with:gamma:lumaGamma:placement:)")
    public func lumaGamma(
        gamma: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            gamma: gamma,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    public func lumaInverted(
        with graphic: Graphic,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            invert: true,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaInverted(with:lumaGamma:placement:)")
    public func lumaInverted(
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            invert: true,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    public func lumaSmoothed(
        with graphic: Graphic,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            smooth: true,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaSmoothed(with:lumaGamma:placement:)")
    public func lumaSmoothed(
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            smooth: true,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    public func lumaOpacity(
        with graphic: Graphic,
        opacity: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            opacity: opacity,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaOpacity(with:opacity:lumaGamma:placement:)")
    public func lumaOpacity(
        opacity: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            opacity: opacity,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    /// Default is 0.0
    public func lumaExposureOffset(
        with graphic: Graphic,
        offset: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            offset: offset,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    /// Default is 0.0
    @available(*, deprecated, renamed: "lumaExposureOffset(with:offset:lumaGamma:placement:)")
    public func lumaExposureOffset(
        offset: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            offset: offset,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    public func lumaAdd(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            offset: value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaAdd(with:value:lumaGamma:placement:)")
    public func lumaAdd(
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            offset: value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    public func lumaSubtract(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            offset: -value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaSubtract(with:value:lumaGamma:placement:)")
    public func lumaSubtract(
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            offset: -value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    public func lumaMultiply(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            brightness: value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaMultiply(with:value:lumaGamma:placement:)")
    public func lumaMultiply(
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            brightness: value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    public func lumaDivide(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            brightness: 1.0 / value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaDivide(with:value:lumaGamma:placement:)")
    public func lumaDivide(
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaLevels(
            brightness: 1.0 / value,
            lumaGamma: lumaGamma,
            placement: placement,
            graphic: graphic
        )
    }
    
    private func lumaLevels(
        brightness: CGFloat = 1.0,
        darkness: CGFloat = 0.0,
        contrast: CGFloat = 0.0,
        gamma: CGFloat = 1.0,
        invert: Bool = false,
        smooth: Bool = false,
        opacity: CGFloat = 1.0,
        offset: CGFloat = 0.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Luma Levels",
            shader: .name("lumaLevels"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: LumaLevelsUniforms(
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
            )
        )
    }
}