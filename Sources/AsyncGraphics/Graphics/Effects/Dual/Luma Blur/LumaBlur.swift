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
        let gamma: Float
    }
   
    private enum LumaBlurType: UInt32 {
        case box
        case angle
        case zoom
        case random
    }
    
    public func lumaBlurredBox(
        with graphic: Graphic,
        radius: CGFloat,
        gamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .box,
            with: graphic,
            radius: radius,
            gamma: gamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
 
    public func lumaBlurredZoom(
        with graphic: Graphic,
        radius: CGFloat,
        center: CGPoint? = nil,
        gamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .zoom,
            with: graphic,
            radius: radius,
            center: center,
            gamma: gamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaBlurredAngle(
        with graphic: Graphic,
        radius: CGFloat,
        angle: Angle,
        gamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .angle,
            with: graphic,
            radius: radius,
            angle: angle,
            gamma: gamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaBlurredRandom(
        with graphic: Graphic,
        radius: CGFloat,
        gamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .random,
            with: graphic,
            radius: radius,
            options: options
        )
    }
    
    private func lumaBlurred(
        type: LumaBlurType,
        with graphic: Graphic,
        radius: CGFloat,
        center: CGPoint? = nil,
        angle: Angle = .zero,
        gamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
            
        let relativeRadius: CGFloat = radius / height
       
        let center: CGPoint = center ?? resolution.asPoint / 2
        let relativeCenter: CGPoint = (center - resolution / 2) / height
        
        return try await Renderer.render(
            name: "Luma Blur",
            shader: .name("lumaBlur"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaBlurUniforms(
                type: type.rawValue,
                placement: placement.index,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                position: relativeCenter.uniform,
                angle: angle.uniform,
                gamma: Float(gamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
