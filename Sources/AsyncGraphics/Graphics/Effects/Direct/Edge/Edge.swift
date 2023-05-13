//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics

extension Graphic {
    
    private struct EdgeUniforms {
        let colored: Bool
        let transparent: Bool
        let includeAlpha: Bool
        let isSobel: Bool
        let amplitude: Float
        let dist: Float
    }
    
    public func edge(amplitude: CGFloat = 1.0,
                     distance: CGFloat = 1.0,
                     options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await edge(amplitude: amplitude,
                       distance: distance,
                       colored: false,
                       options: options)
    }
    
    public func coloredEdge(amplitude: CGFloat = 1.0,
                            distance: CGFloat = 1.0,
                            options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await edge(amplitude: amplitude,
                       distance: distance,
                       colored: true,
                       options: options)
    }
    
    private func edge(amplitude: CGFloat = 1.0,
                      distance: CGFloat = 1.0,
                      colored: Bool,
                      options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Edge",
            shader: .name("edge"),
            graphics: [self],
            uniforms: EdgeUniforms(
                colored: colored,
                transparent: false,
                includeAlpha: false,
                isSobel: false,
                amplitude: Float(amplitude),
                dist: Float(distance)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
