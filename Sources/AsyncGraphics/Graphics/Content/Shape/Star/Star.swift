//
//  Created by Anton Heestand on 2023-04-26.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct StarUniforms {
        let premultiply: Bool
        let count: UInt32
        let innerRadius: Float
        let outerRadius: Float
        let rotation: Float
        let cornerRadius: Float
        let position: PointUniform
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
    }
    
    public static func star(count: Int,
                            innerRadius: CGFloat? = nil,
                            outerRadius: CGFloat? = nil,
                            center: CGPoint? = nil,
                            rotation: Angle = .zero,
                            cornerRadius: CGFloat = 0.0,
                            color: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
        let innerRadius: CGFloat = innerRadius ?? min(resolution.width, resolution.height) / 4
        let outerRadius: CGFloat = outerRadius ?? min(resolution.width, resolution.height) / 2
        
        let relativeInnerRadius: CGFloat = innerRadius / resolution.height
        let relativeOuterRadius: CGFloat = outerRadius / resolution.height
        
        let center: CGPoint = center ?? (resolution.asPoint / 2)
        var relativePosition: CGPoint = (center - resolution / 2) / resolution.height
        // Flip Fix
        relativePosition = CGPoint(x: relativePosition.x, y: -relativePosition.y)

        let relativeCornerRadius: CGFloat = cornerRadius / resolution.height

        return try await Renderer.render(
            name: "Star",
            shader: .name("star"),
            uniforms: StarUniforms(
                premultiply: options.premultiply,
                count: UInt32(count),
                innerRadius: Float(relativeInnerRadius),
                outerRadius: Float(relativeOuterRadius),
                rotation: rotation.uniform,
                cornerRadius: Float(relativeCornerRadius),
                position: relativePosition.uniform,
                foregroundColor: color.uniform,
                backgroundColor: backgroundColor.uniform,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
