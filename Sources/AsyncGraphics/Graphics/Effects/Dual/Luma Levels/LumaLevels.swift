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
            with: graphic,
            brightness: brightness,
            lumaGamma: lumaGamma,
            placement: placement
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
            with: graphic,
            darkness: darkness,
            lumaGamma: lumaGamma,
            placement: placement
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
            with: graphic,
            contrast: contrast,
            lumaGamma: lumaGamma,
            placement: placement
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
            with: graphic,
            gamma: gamma,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    public func lumaInverted(
        with graphic: Graphic,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            with: graphic,
            invert: true,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    public func lumaSmoothed(
        with graphic: Graphic,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            with: graphic,
            smooth: true,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    public func lumaOpacity(
        with graphic: Graphic,
        opacity: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            with: graphic,
            opacity: opacity,
            lumaGamma: lumaGamma,
            placement: placement
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
            with: graphic,
            offset: offset,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    public func lumaAdd(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            with: graphic,
            offset: value,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    public func lumaSubtract(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            with: graphic,
            offset: -value,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    public func lumaMultiply(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            with: graphic,
            brightness: value,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    public func lumaDivide(
        with graphic: Graphic,
        value: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await lumaLevels(
            with: graphic,
            brightness: 1.0 / value,
            lumaGamma: lumaGamma,
            placement: placement
        )
    }
    
    private func lumaLevels(
        with graphic: Graphic,
        brightness: CGFloat = 1.0,
        darkness: CGFloat = 0.0,
        contrast: CGFloat = 0.0,
        gamma: CGFloat = 1.0,
        invert: Bool = false,
        smooth: Bool = false,
        opacity: CGFloat = 1.0,
        offset: CGFloat = 0.0,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Luma Levels",
            shader: .name("lumaLevels"),
            graphics: [
                self,
                graphic
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
