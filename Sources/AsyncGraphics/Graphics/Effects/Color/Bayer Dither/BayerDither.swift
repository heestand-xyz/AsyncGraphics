//
//  BayerDither.swift
//  AsyncGraphics
//
//  Created by Anton Heestand on 2025-07-26.
//

import CoreGraphics

extension Graphic {
    
    private struct BayerDitherUniforms: Uniforms {
        let monochrome: Bool
        let levels: UInt32
        let strength: Float
    }
    
    public func bayerDithered(
        levels: Int = 2,
        strength: CGFloat = 1.0,
        monochrome: Bool,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Bayer Dither",
            shader: .name("bayerDither"),
            graphics: [self],
            uniforms: BayerDitherUniforms(
                monochrome: monochrome,
                levels: UInt32(min(max(levels, 0), 256)),
                strength: Float(strength),
            ),
            options: options.spatialRenderOptions
        )
    }
}

