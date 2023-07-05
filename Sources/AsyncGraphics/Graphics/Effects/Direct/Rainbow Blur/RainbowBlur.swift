//
//  Created by Anton Heestand on 2022-08-26.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI
import TextureMap

extension Graphic {
    
    private struct RainbowBlurUniforms {
        let type: UInt32
        let count: UInt32
        let radius: Float
        let angle: Float
        let light: Float
        let position: PointUniform
    }
    
    private enum RainbowBlurType: UInt32 {
        case circle
        case angle
        case zoom
    }
    
    public func rainbowBlurredCircle(radius: CGFloat,
                                     angle: Angle = .zero,
                                     light: CGFloat = 1.0,
                                     sampleCount: Int = 100,
                                     options: EffectOptions = []) async throws -> Graphic {
        
        try await rainbowBlurred(type: .circle, radius: radius, angle: angle, light: light, sampleCount: sampleCount, options: options)
    }
    
    public func rainbowBlurredZoom(radius: CGFloat,
                                   center: CGPoint? = nil,
                                   light: CGFloat = 1.0,
                                   sampleCount: Int = 100,
                                   options: EffectOptions = []) async throws -> Graphic {
        
        try await rainbowBlurred(type: .zoom, radius: radius, center: center, light: light, sampleCount: sampleCount, options: options)
    }
    
    public func rainbowBlurredAngle(radius: CGFloat,
                                    angle: Angle,
                                    light: CGFloat = 1.0,
                                    sampleCount: Int = 100,
                                    options: EffectOptions = []) async throws -> Graphic {
        
        try await rainbowBlurred(type: .angle, radius: radius, angle: angle, light: light, sampleCount: sampleCount, options: options)
    }
    
    private func rainbowBlurred(type: RainbowBlurType,
                                radius: CGFloat,
                                center: CGPoint? = nil,
                                angle: Angle = .zero,
                                light: CGFloat = 1.0,
                                sampleCount: Int = 100,
                                options: EffectOptions = []) async throws -> Graphic {
        
        let center: CGPoint = center ?? resolution.asPoint / 2
        let relativeCenter: CGPoint = (center - resolution / 2) / height
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Rainbow Blur",
            shader: .name("rainbowBlur"),
            graphics: [self],
            uniforms: RainbowBlurUniforms(
                type: type.rawValue,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                angle: angle.uniform,
                light: Float(light),
                position: relativeCenter.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}

