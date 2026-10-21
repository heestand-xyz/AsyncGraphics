//
//  Created by Anton Heestand on 2022-08-26.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct PolygonUniforms: Uniforms {
        let radius: Float
        let position: PointUniform
        let rotation: Float
        let count: UInt32
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
        let cornerRadius: Float
        let premultiply: Bool
        let antiAlias: Bool
        let resolution: SizeUniform
        let tileOrigin: PointUniform
        let tileSize: SizeUniform
    }
    
    public static func polygon(count: Int,
                               radius: CGFloat? = nil,
                               position: CGPoint? = nil,
                               rotation: Angle = .zero,
                               cornerRadius: CGFloat = 0.0,
                               stroke: StrokeStyle? = nil,
                               color: PixelColor = .white,
                               backgroundColor: PixelColor = .black,
                               resolution: CGSize,
                               tile: Tile = .one,
                               options: ContentOptions = []) async throws -> Graphic {
        
        let radius: CGFloat = radius ?? min(resolution.width, resolution.height) / 2
        
        let position: CGPoint = position ?? (resolution.asPoint / 2)
        guard resolution.width.isFinite, resolution.height.isFinite,
              resolution.width > 0, resolution.height > 0 else {
            throw ShapePathError.invalidResolution
        }
        guard radius.isFinite, Float(radius).isFinite,
              position.x.isFinite, position.y.isFinite,
              Float(position.x).isFinite, Float(position.y).isFinite,
              rotation.radians.isFinite else {
            throw ShapePathError.invalidPath
        }
        guard cornerRadius.isFinite else { throw ShapePathError.invalidCornerRadius }
        guard count >= 3 else {
            return try await path(CGMutablePath(), stroke: stroke, color: color, backgroundColor: backgroundColor,
                                  resolution: resolution, tile: tile, options: options)
        }
        guard count <= 65_536 else { throw ShapePathError.excessiveComplexity }
        let rounding = min(max(cornerRadius, 0), max(radius, 0) * cos(.pi / CGFloat(count)))
        if let stroke {
            let contour: CGPath
            if radius <= 0 {
                contour = CGMutablePath()
            } else if rounding >= radius * cos(.pi / CGFloat(count)) {
                var transform = CGAffineTransform(translationX: position.x, y: position.y)
                    .rotated(by: -CGFloat(rotation.radians))
                contour = CGPath(ellipseIn: CGRect(x: -rounding, y: -rounding,
                                                  width: rounding * 2, height: rounding * 2), transform: &transform)
            } else {
                let points = (0..<count).map { index -> CGPoint in
                    let angle = CGFloat(index) / CGFloat(count) * .pi * 2 - CGFloat(rotation.radians)
                    return CGPoint(x: position.x + sin(angle) * radius, y: position.y - cos(angle) * radius)
                }
                contour = try roundedPolylinePath(points: points, cornerRadius: rounding, closed: true)
            }
            return try await path(contour, stroke: stroke, color: color, backgroundColor: backgroundColor,
                                  resolution: resolution, tile: tile, options: options)
        }

        return try await Renderer.render(
            name: "Polygon",
            shader: .name("polygon"),
            uniforms: PolygonUniforms(
                radius: Float(radius),
                position: position.uniform,
                rotation: Float(rotation.radians.truncatingRemainder(dividingBy: .pi * 2)),
                count: UInt32(count),
                foregroundColor: color.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                cornerRadius: Float(rounding),
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            )
        )
    }
}
