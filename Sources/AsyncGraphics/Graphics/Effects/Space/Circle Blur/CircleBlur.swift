//
//  Created by Anton Heestand on 2022-04-07.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI
import TextureMap

extension Graphic {
    
    private struct CircleBlurUniforms: Uniforms {
        let count: UInt32
        let radius: Float
        let brightnessLow: Float
        let brightnessHigh: Float
        let saturationLow: Float
        let saturationHigh: Float
        let light: Float
    }
    
    public func blurredCircle(
        radius: CGFloat,
        sampleCount: Int = 100,
        brightnessRange: ClosedRange<CGFloat> = 0.0...1.0,
        saturationRange: ClosedRange<CGFloat> = 0.0...1.0,
        light: CGFloat = 1.0,
        options: EffectOptions = .edgeStretch
    ) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Circle Blur",
            shader: .name("circleBlur"),
            graphics: [self],
            uniforms: CircleBlurUniforms(
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                brightnessLow: Float(brightnessRange.lowerBound),
                brightnessHigh: Float(brightnessRange.upperBound),
                saturationLow: Float(saturationRange.lowerBound),
                saturationHigh: Float(saturationRange.upperBound),
                light: Float(light)
            ),
            options: options.spatialRenderOptions
        )
    }
}

