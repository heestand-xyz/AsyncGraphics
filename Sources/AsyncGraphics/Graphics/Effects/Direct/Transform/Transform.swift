//
//  Created by Anton Heestand on 2022-04-14.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    private struct TransformUniforms {
        let translation: PointUniform
        let rotation: Float
        let scale: Float
        let size: SizeUniform
    }
    
    public func translated(_ translation: CGPoint,
                           options: EffectOptions = EffectOptions()) async throws -> Graphic {
        try await transformed(translation: translation, options: options)
    }
    
    public func translated(x: CGFloat = 0.0, y: CGFloat = 0.0,
                           options: EffectOptions = EffectOptions()) async throws -> Graphic {
        try await transformed(translation: CGPoint(x: x, y: y), options: options)
    }
    
    public func rotated(_ rotation: Angle,
                        options: EffectOptions = EffectOptions()) async throws -> Graphic {
        try await transformed(rotation: rotation, options: options)
    }
    
    public func scaled(_ scale: CGFloat,
                       options: EffectOptions = EffectOptions()) async throws -> Graphic {
        try await transformed(scale: scale, options: options)
    }
    
    public func scaled(x: CGFloat = 1.0, y: CGFloat = 1.0,
                       options: EffectOptions = EffectOptions()) async throws -> Graphic {
        try await transformed(scaleSize: CGSize(width: x, height: y), options: options)
    }
    
    public func transformed(translation: CGPoint = .zero,
                            rotation: Angle = .zero,
                            scale: CGFloat = 1.0,
                            scaleSize: CGSize = CGSize(width: 1.0, height: 1.0),
                            options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        let relativeTranslation: CGPoint = translation / resolution.height
        
        return try await Renderer.render(
            name: "Transform",
            shader: .name("transform"),
            graphics: [self],
            uniforms: TransformUniforms(
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: scaleSize.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
