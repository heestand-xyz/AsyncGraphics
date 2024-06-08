//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics

extension Graphic {
    
    private struct EdgeUniforms {
        let isColored: Bool
        let isTransparent: Bool
        let includeAlpha: Bool
        let isSobel: Bool
        let amplitude: Float
        let dist: Float
    }
    
    public func edge(
        amplitude: CGFloat = 1.0,
        distance: CGFloat = 1.0,
        isTransparent: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await edge(
            amplitude: amplitude,
            distance: distance,
            isColored: false,
            isTransparent: isTransparent,
            options: options
        )
    }
    
    public func coloredEdge(
        amplitude: CGFloat = 1.0,
        distance: CGFloat = 1.0,
        isTransparent: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await edge(
            amplitude: amplitude,
            distance: distance,
            isColored: true,
            isTransparent: isTransparent,
            options: options
        )
    }
    
    func edge(
        amplitude: CGFloat = 1.0,
        distance: CGFloat = 1.0,
        isColored: Bool = false,
        isTransparent: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Edge",
            shader: .name("edge"),
            graphics: [self],
            uniforms: EdgeUniforms(
                isColored: isColored,
                isTransparent: isTransparent,
                includeAlpha: false,
                isSobel: false,
                amplitude: Float(amplitude),
                dist: Float(distance)
            ),
            options: options.renderOptions
        )
    }
}
