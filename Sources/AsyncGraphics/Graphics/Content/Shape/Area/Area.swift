import CoreGraphics
import PixelColor

extension Graphic {

    /// Fills an arbitrary closed polygon. Points use pixel coordinates measured
    /// from the upper-left corner; a positive corner radius rounds each vertex.
    public static func area(
        points: [CGPoint],
        cornerRadius: CGFloat = 0,
        stroke: StrokeStyle? = nil,
        fillRule: CGPathFillRule = .winding,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        resolution: CGSize,
        tile: Tile = .one,
        options: ContentOptions = []
    ) async throws -> Graphic {
        let contour = try roundedPolylinePath(points: points, cornerRadius: cornerRadius, closed: true)
        return try await path(
            contour,
            stroke: stroke,
            fillRule: fillRule,
            color: color,
            backgroundColor: backgroundColor,
            resolution: resolution,
            tile: tile,
            options: options
        )
    }
}
