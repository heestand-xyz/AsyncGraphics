//
//  Created by Anton Heestand on 2022-08-21.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor
import SwiftUI

extension Graphic {

    private struct ArcUniforms {
        let premultiply: Bool
        let antiAlias: Bool
        let angleCenter: Float
        let angleLength: Float
        let radius: Float
        let position: PointUniform
        let edgeRadius: Float
        let foregroundColor: ColorUniform
        let edgeColor: ColorUniform
        let backgroundColor: ColorUniform
        let resolution: SizeUniform
    }
    
    public static func arc(angle: Angle,
                           length: Angle,
                           radius: CGFloat? = nil,
                           position: CGPoint? = nil,
                           color: PixelColor = .white,
                           backgroundColor: PixelColor = .black,
                           resolution: CGSize,
                           options: ContentOptions = []) async throws -> Graphic {

        let radius: CGFloat = radius ?? min(resolution.width, resolution.height) / 2
        let relativeRadius: CGFloat = radius / resolution.height

        let position: CGPoint = position ?? (resolution.asPoint / 2)
        let relativePosition: CGPoint = (position - resolution / 2) / resolution.height

        return try await Renderer.render(
            name: "Arc",
            shader: .name("arc"),
            uniforms: ArcUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                angleCenter: angle.uniform,
                angleLength: length.uniform,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: 0.0,
                foregroundColor: color.uniform,
                edgeColor: PixelColor.clear.uniform,
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

    public static func strokedArc(angle: Angle,
                                  length: Angle,
                                  radius: CGFloat? = nil,
                                  position: CGPoint? = nil,
                                  lineWidth: CGFloat,
                                  color: PixelColor = .white,
                                  backgroundColor: PixelColor = .black,
                                  resolution: CGSize,
                                  options: ContentOptions = []) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? min(resolution.width, resolution.height) / 2
        let relativeRadius: CGFloat = radius / resolution.height

        let position: CGPoint = position ?? (resolution / 2).asPoint
        let relativePosition: CGPoint = (position - resolution / 2) / resolution.height

        let relativeLineWidth: CGFloat = lineWidth / resolution.height

        return try await Renderer.render(
            name: "Arc",
            shader: .name("arc"),
            uniforms: ArcUniforms(
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                angleCenter: angle.uniform,
                angleLength: length.uniform,
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                edgeRadius: Float(relativeLineWidth),
                foregroundColor: backgroundColor.uniform,
                edgeColor: color.uniform,
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
