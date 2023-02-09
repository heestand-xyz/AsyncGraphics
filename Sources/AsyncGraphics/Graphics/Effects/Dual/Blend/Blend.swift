//
//  Created by Anton Heestand on 2022-04-03.
//

import Metal
import SwiftUI
import CoreGraphicsExtensions

extension Graphic {
    
    private struct BlendUniforms {
        let transform: Bool
        let blendingMode: Int32
        let placement: Int32
        let translation: PointUniform
        let rotation: Float
        let scale: Float
        let size: SizeUniform
    }
    
    public func blended(
        with graphic: Graphic,
        blendingMode: BlendingMode,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blend",
            shader: .name("blend"),
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                transform: false,
                blendingMode: Int32(blendingMode.index),
                placement: Int32(placement.index),
                translation: .zero,
                rotation: 0.0,
                scale: 0.0,
                size: .one
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
    
    public func transformBlended(
        with graphic: Graphic,
        blendingMode: BlendingMode,
        placement: Placement = .fit,
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        size: CGSize? = nil,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
       
        let relativeTranslation: CGPoint = translation / resolution.height
        let relativeSize: CGSize = (size ?? resolution) / resolution

        return try await Renderer.render(
            name: "Blend with Transform",
            shader: .name("blend"),
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                transform: true,
                blendingMode: Int32(blendingMode.index),
                placement: Int32(placement.index),
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: relativeSize.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
    
    public static func mask(
        foreground foregroundGraphic: Graphic,
        background backgroundGraphic: Graphic,
        mask maskGraphic: Graphic,
        placement: Placement = .fit,
        options: EffectOptions = EffectOptions()
    ) async throws -> Graphic {
        let alphaGraphic = try await maskGraphic.luminanceToAlpha()
        let graphic = try await foregroundGraphic.blended(with: alphaGraphic, blendingMode: .multiply, placement: placement)
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over, placement: placement)
    }
}
