//
//  Created by Anton Heestand on 2022-08-26.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct PolygonUniforms {
        let radius: Float
        let position: PointUniform
        let rotation: Float
        let count: UInt8
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
        let cornerRadius: Float
        let premultiply: Bool
        let resolution: SizeUniform
    }
    
    public static func polygon(count: Int,
                               radius: CGFloat? = nil,
                               center: CGPoint? = nil,
                               rotation: Angle = .zero,
                               cornerRadius: CGFloat = 0.0,
                               color: PixelColor = .white,
                               backgroundColor: PixelColor = .black,
                               resolution: CGSize,
                               options: ContentOptions = ContentOptions()) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? min(resolution.width, resolution.height) / 2
        
        let relativeRadius: CGFloat = radius / resolution.height
        
        let center: CGPoint = center ?? (resolution.asPoint / 2)
        let relativePosition: CGPoint = (center - resolution / 2) / resolution.height

        let relativeCornerRadius: CGFloat = cornerRadius / resolution.height

        return try await Renderer.render(
            name: "Polygon",
            shader: .name("polygon"),
            uniforms: PolygonUniforms(
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                rotation: rotation.uniform,
                count: UInt8(count),
                foregroundColor: color.uniform,
                backgroundColor: backgroundColor.uniform,
                cornerRadius: Float(relativeCornerRadius),
                premultiply: options.premultiply,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(
                filter: options.filter
            )
        )
    }
}
