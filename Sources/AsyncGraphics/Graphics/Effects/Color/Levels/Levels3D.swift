//
//  Created by Anton Heestand on 2022-04-22.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Levels3DUniforms: Uniforms {
        let brightness: Float
        let darkness: Float
        let contrast: Float
        let gamma: Float
        let invert: Bool
        let smooth: Bool
        let opacity: Float
        let offset: Float
        let premultiply: Bool
        let padding: SIMD3<Float> = .zero
    }
    
    /// Default is 1.0
    public func brightness(
        _ brightness: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            brightness: brightness,
            options: options
        )
    }
    
    /// Default is 0.0
    public func darkness(
        _ darkness: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            darkness: darkness,
            options: options
        )
    }
    
    /// Default is 0.0
    public func contrast(
        _ contrast: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            contrast: contrast,
            options: options
        )
    }
    
    /// Default is 1.0
    public func gamma(
        _ gamma: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            gamma: gamma,
            options: options
        )
    }
    
    public func inverted(
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            invert: true,
            options: options
        )
    }
    
    public func smoothed(
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            smooth: true,
            options: options
        )
    }
    
    public func opacity(
        _ opacity: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            opacity: opacity,
            options: options
        )
    }
    
    /// Default is 0.0
    public func exposureOffset(
        _ offset: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await levels(
            offset: offset,
            options: options
        )
    }
    
    public func levels(
        brightness: CGFloat = 1.0,
        darkness: CGFloat = 0.0,
        contrast: CGFloat = 0.0,
        gamma: CGFloat = 1.0,
        invert: Bool = false,
        smooth: Bool = false,
        opacity: CGFloat = 1.0,
        offset: CGFloat = 0.0,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Levels 3D",
            shader: .name("levels3d"),
            graphics: [self],
            uniforms: Levels3DUniforms(
                brightness: Float(brightness),
                darkness: Float(darkness),
                contrast: Float(contrast),
                gamma: Float(gamma),
                invert: invert,
                smooth: smooth,
                opacity: Float(opacity),
                offset: Float(offset),
                premultiply: options.premultiply
            ),
            options: options.colorRenderOptions
        )
    }
}
