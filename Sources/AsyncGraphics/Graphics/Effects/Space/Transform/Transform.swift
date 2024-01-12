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
    
    public func offset(_ translation: CGPoint,
                       options: EffectOptions = []) async throws -> Graphic {
        try await transformed(translation: translation, options: options)
    }
    
    public func offset(x: CGFloat = 0.0, y: CGFloat = 0.0,
                       options: EffectOptions = []) async throws -> Graphic {
        try await transformed(translation: CGPoint(x: x, y: y), options: options)
    }
    
    public func rotated(_ rotation: Angle,
                        options: EffectOptions = []) async throws -> Graphic {
        try await transformed(rotation: rotation, options: options)
    }
    
    public func scaled(_ scale: CGFloat,
                       options: EffectOptions = []) async throws -> Graphic {
        try await transformed(scale: scale, options: options)
    }
    
    public func sized(width: CGFloat? = nil, height: CGFloat? = nil,
                       options: EffectOptions = []) async throws -> Graphic {
        try await transformed(size: CGSize(width: width ?? resolution.width,
                                           height: height ?? resolution.height), options: options)
    }
    
    public func sized(_ size: CGSize,
                      options: EffectOptions = []) async throws -> Graphic {
        try await transformed(size: size, options: options)
    }
    
    public func transformed(
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        size: CGSize? = nil,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let relativeTranslation: CGPoint = translation / resolution.height
        let relativeSize: CGSize = (size ?? resolution) / resolution

        return try await Renderer.render(
            name: "Transform",
            shader: .name("transform"),
            graphics: [self],
            uniforms: TransformUniforms(
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: relativeSize.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
