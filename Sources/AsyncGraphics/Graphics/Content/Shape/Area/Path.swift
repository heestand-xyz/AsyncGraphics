import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {

    private struct PathUniforms: Uniforms {
        let segmentCount: UInt32
        let evenOdd: Bool
        let premultiply: Bool
        let antiAlias: Bool
        let foregroundColor: ColorUniform
        let backgroundColor: ColorUniform
        let boundsMinimum: PointUniform
        let boundsMaximum: PointUniform
        let resolution: SizeUniform
        let tileOrigin: PointUniform
        let tileSize: SizeUniform
    }

    private struct PathSegmentUniform: Uniforms {
        let leading: PointUniform
        let trailing: PointUniform
    }

    /// Fills a Core Graphics path on the GPU. Coordinates and stroke widths are
    /// measured in pixels from the upper-left corner of the full resolution.
    /// Curves are flattened to a maximum deviation of one eighth of a pixel.
    public static func path(
        _ path: CGPath,
        stroke: StrokeStyle? = nil,
        fillRule: CGPathFillRule = .winding,
        color: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        resolution: CGSize,
        tile: Tile = .one,
        options: ContentOptions = []
    ) async throws -> Graphic {
        guard resolution.width.isFinite, resolution.height.isFinite,
              resolution.width > 0, resolution.height > 0 else {
            throw ShapePathError.invalidResolution
        }

        let outline = try stroke.map { try strokeOutline(of: path, style: $0) } ?? path
        var flattener = PathFlattener()
        outline.applyWithBlock { flattener.consume($0.pointee) }
        flattener.finishContour()
        if let error = flattener.error { throw error }

        let segments = flattener.segments
        let bounds = flattener.bounds
        // Metal still needs a bound buffer for an empty path, even though the
        // shader returns the background before accessing any of its elements.
        let emptySegment = PathSegmentUniform(leading: .zero, trailing: .zero)
        let bufferSegments = segments.isEmpty ? [emptySegment] : segments
        return try await Renderer.render(
            name: "Path",
            shader: .name("areaPath"),
            uniforms: PathUniforms(
                segmentCount: UInt32(segments.count),
                evenOdd: fillRule == .evenOdd,
                premultiply: options.premultiply,
                antiAlias: options.antiAlias,
                foregroundColor: color.uniform,
                backgroundColor: options.pureTranslucentBackgroundColor(backgroundColor, color: color).uniform,
                boundsMinimum: bounds.isNull ? .zero : bounds.origin.uniform,
                boundsMaximum: bounds.isNull ? .zero : CGPoint(x: bounds.maxX, y: bounds.maxY).uniform,
                resolution: resolution.uniform,
                tileOrigin: tile.uvOrigin,
                tileSize: tile.uvSize
            ),
            arrayUniforms: bufferSegments,
            emptyArrayUniform: emptySegment,
            metadata: Renderer.Metadata(
                resolution: tile.resolution(at: resolution),
                colorSpace: options.colorSpace,
                bits: options.bits
            ),
            options: Renderer.Options(overrideUniformArrayMaxLimit: bufferSegments.count)
        )
    }

    private struct PathFlattener {
        private static let toleranceSquared: CGFloat = 0.125 * 0.125
        private static let maximumSegments = 65_536
        private static let maximumDepth = 20

        var segments: [PathSegmentUniform] = []
        var bounds: CGRect = .null
        var error: ShapePathError?
        private var contour: [CGPoint] = []
        private var currentPoint: CGPoint = .zero

        mutating func consume(_ element: CGPathElement) {
            guard error == nil else { return }
            switch element.type {
            case .moveToPoint:
                finishContour()
                append(element.points[0])
            case .addLineToPoint:
                beginContourIfNeeded()
                append(element.points[0])
            case .addQuadCurveToPoint:
                beginContourIfNeeded()
                let control = element.points[0]
                let end = element.points[1]
                guard validate(control), validate(end) else { return }
                flattenQuadratic(currentPoint, control, end, depth: 0)
            case .addCurveToPoint:
                beginContourIfNeeded()
                let control1 = element.points[0]
                let control2 = element.points[1]
                let end = element.points[2]
                guard validate(control1), validate(control2), validate(end) else { return }
                flattenCubic(currentPoint, control1, control2, end, depth: 0)
            case .closeSubpath:
                let start = contour.first
                finishContour()
                if let start { currentPoint = start }
            @unknown default:
                error = .invalidPath
            }
        }

        mutating func finishContour() {
            guard error == nil else { return }
            if !contour.isEmpty, contour.last == contour.first { contour.removeLast() }
            if contour.count >= 3 {
                guard segments.count + contour.count <= Self.maximumSegments else {
                    error = .excessiveComplexity
                    return
                }
                for index in contour.indices {
                    let leading = contour[index]
                    let trailing = contour[(index + 1) % contour.count]
                    segments.append(PathSegmentUniform(leading: leading.uniform, trailing: trailing.uniform))
                    if bounds.isNull {
                        bounds = CGRect(origin: leading, size: .zero)
                    } else {
                        let minX = min(bounds.minX, leading.x)
                        let minY = min(bounds.minY, leading.y)
                        let maxX = max(bounds.maxX, leading.x)
                        let maxY = max(bounds.maxY, leading.y)
                        bounds = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                    }
                }
            }
            contour.removeAll(keepingCapacity: true)
        }

        private mutating func beginContourIfNeeded() {
            if contour.isEmpty { append(currentPoint) }
        }

        private mutating func validate(_ point: CGPoint) -> Bool {
            guard point.x.isFinite, point.y.isFinite,
                  Float(point.x).isFinite, Float(point.y).isFinite else {
                error = .invalidPath
                return false
            }
            return true
        }

        private mutating func append(_ point: CGPoint) {
            guard error == nil, validate(point) else { return }
            if contour.last != point { contour.append(point) }
            currentPoint = point
            if segments.count + contour.count > Self.maximumSegments {
                error = .excessiveComplexity
            }
        }

        private mutating func flattenQuadratic(_ start: CGPoint, _ control: CGPoint, _ end: CGPoint, depth: Int) {
            guard error == nil else { return }
            if Self.squaredDistance(control, toSegmentFrom: start, to: end) <= Self.toleranceSquared {
                append(end)
                return
            }
            guard depth < Self.maximumDepth else {
                error = .excessiveComplexity
                return
            }
            let first = Self.midpoint(start, control)
            let second = Self.midpoint(control, end)
            let middle = Self.midpoint(first, second)
            flattenQuadratic(start, first, middle, depth: depth + 1)
            flattenQuadratic(middle, second, end, depth: depth + 1)
        }

        private mutating func flattenCubic(_ start: CGPoint, _ first: CGPoint, _ second: CGPoint, _ end: CGPoint, depth: Int) {
            guard error == nil else { return }
            if max(Self.squaredDistance(first, toSegmentFrom: start, to: end),
                   Self.squaredDistance(second, toSegmentFrom: start, to: end)) <= Self.toleranceSquared {
                append(end)
                return
            }
            guard depth < Self.maximumDepth else {
                error = .excessiveComplexity
                return
            }
            let a = Self.midpoint(start, first)
            let b = Self.midpoint(first, second)
            let c = Self.midpoint(second, end)
            let d = Self.midpoint(a, b)
            let e = Self.midpoint(b, c)
            let middle = Self.midpoint(d, e)
            flattenCubic(start, a, d, middle, depth: depth + 1)
            flattenCubic(middle, e, c, end, depth: depth + 1)
        }

        private static func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
            CGPoint(x: a.x / 2 + b.x / 2, y: a.y / 2 + b.y / 2)
        }

        private static func squaredDistance(_ point: CGPoint, toSegmentFrom start: CGPoint, to end: CGPoint) -> CGFloat {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let lengthSquared = dx * dx + dy * dy
            let fraction = lengthSquared > 0
                ? min(max(((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared, 0), 1)
                : 0
            let x = point.x - (start.x + fraction * dx)
            let y = point.y - (start.y + fraction * dy)
            return x * x + y * y
        }
    }
}
