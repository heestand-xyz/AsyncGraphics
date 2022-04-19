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
    
    public func translated(_ translation: CGPoint) async throws -> Graphic {
        try await transformed(translation: translation)
    }
    
    public func translated(x: CGFloat = 0.0, y: CGFloat = 0.0) async throws -> Graphic {
        try await transformed(translation: CGPoint(x: x, y: y))
    }
    
    public func rotated(_ rotation: Angle) async throws -> Graphic {
        try await transformed(rotation: rotation)
    }
    
    public func scaled(_ scale: CGFloat) async throws -> Graphic {
        try await transformed(scale: scale)
    }
    
    public func scaled(x: CGFloat = 1.0, y: CGFloat = 1.0) async throws -> Graphic {
        try await transformed(scaleSize: CGSize(width: x, height: y))
    }
    
    private func transformed(
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        scaleSize: CGSize = CGSize(width: 1.0, height: 1.0)
    ) async throws -> Graphic {
        
        let relativeTranslation: CGPoint = translation.flipTranslationY(size: size) / size.height
        
        return try await Renderer.render(
            name: "Transform",
            shaderName: "transform",
            graphics: [self],
            uniforms: TransformUniforms(
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: scaleSize.uniform
            )
        )
    }
}
