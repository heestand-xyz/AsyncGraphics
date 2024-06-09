//
//  Created by Anton Heestand on 2022-08-26.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    private struct KaleidoscopeUniforms {
        let mirror: Bool
        let divisions: UInt32
        let rotation: Float
        let scale: Float
        let position: PointUniform
    }
    
    public func kaleidoscope(
        count: Int = 12,
        mirror: Bool = true,
        position: CGPoint? = nil,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        options: EffectOptions = .edgeMirror
    ) async throws -> Graphic {
        
        let position: CGPoint = position ?? (resolution.asPoint / 2)
        let relativePosition: CGPoint = (position - resolution / 2) / resolution.height

        return try await Renderer.render(
            name: "Kaleidoscope",
            shader: .name("kaleidoscope"),
            graphics: [self],
            uniforms: KaleidoscopeUniforms(
                mirror: mirror,
                divisions: UInt32(count),
                rotation: rotation.uniform,
                scale: Float(scale),
                position: relativePosition.uniform
            ),
            options: options.spatialRenderOptions
        )
    }
}
