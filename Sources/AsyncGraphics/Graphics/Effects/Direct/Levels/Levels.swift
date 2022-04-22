//
//  Created by Anton Heestand on 2022-04-22.
//

import CoreGraphics

extension Graphic {
    
    private struct LevelsUniforms {
        let brightness: Float
        let darkness: Float
        let contrast: Float
        let gamma: Float
        let invert: Bool
        let smooth: Bool
        let opacity: Float
        let offset: Float
    }
    
    /// Default is 1.0
    public func brightness(_ brightness: CGFloat) async throws -> Graphic {
        
        try await levels(brightness: brightness)
    }
    
    /// Default is 0.0
    public func darkness(_ darkness: CGFloat) async throws -> Graphic {
        
        try await levels(darkness: darkness)
    }
    
    /// Default is 0.0
    public func contrast(_ contrast: CGFloat) async throws -> Graphic {
        
        try await levels(contrast: contrast)
    }
    
    /// Default is 1.0
    public func gamma(_ gamma: CGFloat) async throws -> Graphic {
        
        try await levels(gamma: gamma)
    }
    
    public func inverted() async throws -> Graphic {
        
        try await levels(invert: true)
    }
    
    public func smoothed() async throws -> Graphic {
        
        try await levels(smooth: true)
    }
    
    public func opacity(_ opacity: CGFloat) async throws -> Graphic {
        
        try await levels(opacity: opacity)
    }
    
    /// Default is 0.0
    public func exposureOffset(_ offset: CGFloat) async throws -> Graphic {
        
        try await levels(offset: offset)
    }
    
    private func levels(brightness: CGFloat = 1.0,
                        darkness: CGFloat = 0.0,
                        contrast: CGFloat = 0.0,
                        gamma: CGFloat = 1.0,
                        invert: Bool = false,
                        smooth: Bool = false,
                        opacity: CGFloat = 1.0,
                        offset: CGFloat = 0.0) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Levels",
            shader: .name("levels"),
            graphics: [self],
            uniforms: LevelsUniforms(
                brightness: Float(brightness),
                darkness: Float(darkness),
                contrast: Float(contrast),
                gamma: Float(gamma),
                invert: invert,
                smooth: smooth,
                opacity: Float(opacity),
                offset: Float(offset)
            )
        )
    }
}
