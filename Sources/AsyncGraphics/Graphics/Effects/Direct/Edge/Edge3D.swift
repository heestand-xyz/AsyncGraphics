//
//  Created by Anton Heestand on 2022-04-27.
//

extension Graphic3D {
    
    private struct Edge3DUniforms {
        let colored: Bool
        let transparent: Bool
        let includeAlpha: Bool
        let amplitude: Float
        let dist: Float
    }
    
    public func edge(amplitude: Double = 1.0,
                     distance: Double = 1.0,
                     options: EffectOptions = EffectOptions()) async throws -> Graphic3D {
        
        try await edge(amplitude: amplitude,
                       distance: distance,
                       colored: false,
                       options: options)
    }
    
    public func coloredEdge(amplitude: Double = 1.0,
                            distance: Double = 1.0,
                            options: EffectOptions = EffectOptions()) async throws -> Graphic3D {
        
        try await edge(amplitude: amplitude,
                       distance: distance,
                       colored: true,
                       options: options)
    }
    
    private func edge(amplitude: Double = 1.0,
                      distance: Double = 1.0,
                      colored: Bool,
                      options: EffectOptions = EffectOptions()) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Edge",
            shader: .name("edge3d"),
            graphics: [self],
            uniforms: Edge3DUniforms(
                colored: colored,
                transparent: false,
                includeAlpha: false,
                amplitude: Float(amplitude),
                dist: Float(distance)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
