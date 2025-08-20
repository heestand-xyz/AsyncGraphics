//
//  Created by Anton Heestand on 2022-04-27.
//

extension Graphic3D {
    
    private struct Edge3DUniforms: Uniforms {
        let isColored: Bool
        let isTransparent: Bool
        let includeAlpha: Bool
        let amplitude: Float
        let dist: Float
    }
    
    public func edge(
        amplitude: Double = 1.0,
        distance: Double = 1.0,
        isTransparent: Bool = true,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await edge(
            amplitude: amplitude,
            distance: distance,
            isColored: false,
            isTransparent: isTransparent,
            options: options
        )
    }
    
    public func coloredEdge(
        amplitude: Double = 1.0,
        distance: Double = 1.0,
        isTransparent: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await edge(
            amplitude: amplitude,
            distance: distance,
            isColored: true,
            isTransparent: isTransparent,
            options: options
        )
    }
    
    func edge(
        amplitude: Double = 1.0,
        distance: Double = 1.0,
        isColored: Bool = false,
        isTransparent: Bool = false,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Edge 3D",
            shader: .name("edge3d"),
            graphics: [self],
            uniforms: Edge3DUniforms(
                isColored: isColored,
                isTransparent: isTransparent,
                includeAlpha: false,
                amplitude: Float(amplitude),
                dist: Float(distance)
            ),
            options: options.spatialRenderOptions
        )
    }
}
