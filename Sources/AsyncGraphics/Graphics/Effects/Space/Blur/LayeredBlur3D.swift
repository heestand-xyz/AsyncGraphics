//
//  Created by Anton Heestand on 2026-08-17.
//

import CoreGraphics

extension Graphic3D {

    private struct LayeredBlur3DUniforms: Uniforms {
        let radius: Float
    }

    public func blurredLayered(
        radius: CGFloat,
        layerCount: Int = 10,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        guard layerCount > 0 else { return self }

        var blurredGraphic: Graphic3D = self
        var layerRadius: CGFloat = radius
        for _ in 0..<layerCount {
            blurredGraphic = try await blurredGraphic.blurredLayeredSinglePass(
                radius: layerRadius,
                options: options
            )
            layerRadius /= 2.0
        }
        return blurredGraphic
    }

    public func blurredLayeredSinglePass(
        radius: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        let relativeRadius: CGFloat = radius / CGFloat(height)

        return try await Renderer.render(
            name: "Blur 3D (Layered)",
            shader: .name("layeredBlur3d"),
            graphics: [self],
            uniforms: LayeredBlur3DUniforms(radius: Float(relativeRadius)),
            options: options.spatialRenderOptions
        )
    }
}
