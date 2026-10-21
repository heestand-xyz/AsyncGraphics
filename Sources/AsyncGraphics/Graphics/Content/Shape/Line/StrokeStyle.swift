import CoreGraphics
import Foundation

extension Graphic {

    /// Stroke geometry in pixels, including the dash pattern and its phase.
    public struct StrokeStyle: Sendable {
        public var lineWidth: CGFloat
        public var lineCap: CGLineCap
        public var lineJoin: CGLineJoin
        public var miterLimit: CGFloat
        public var dash: [CGFloat]
        public var dashPhase: CGFloat

        public init(lineWidth: CGFloat = 1.0,
                    lineCap: CGLineCap = .butt,
                    lineJoin: CGLineJoin = .miter,
                    miterLimit: CGFloat = 10.0,
                    dash: [CGFloat] = [],
                    dashPhase: CGFloat = 0.0) {
            self.lineWidth = lineWidth
            self.lineCap = lineCap
            self.lineJoin = lineJoin
            self.miterLimit = miterLimit
            self.dash = dash
            self.dashPhase = dashPhase
        }
    }

    public enum ShapePathError: Error, LocalizedError, Sendable {
        case invalidPath
        case invalidResolution
        case invalidCornerRadius
        case invalidStrokeStyle
        case excessiveComplexity

        public var errorDescription: String? {
            switch self {
            case .invalidPath:
                return "Shape path coordinates must be finite."
            case .invalidResolution:
                return "Shape resolution must be finite and greater than zero."
            case .invalidCornerRadius:
                return "Shape corner radius must be finite and nonnegative."
            case .invalidStrokeStyle:
                return "Stroke width, miter limit, and dash lengths must be finite and nonnegative; a dash pattern must have a positive total length and a finite phase."
            case .excessiveComplexity:
                return "The shape path is too complex to render safely."
            }
        }
    }

    /// CoreGraphics constructs vector outlines only; coverage is rendered on the GPU.
    static func strokeOutline(of path: CGPath, style: StrokeStyle) throws -> CGPath {
        var hasFinitePoints = true
        path.applyWithBlock { elementPointer in
            let element = elementPointer.pointee
            let pointCount: Int
            switch element.type {
            case .moveToPoint, .addLineToPoint: pointCount = 1
            case .addQuadCurveToPoint: pointCount = 2
            case .addCurveToPoint: pointCount = 3
            case .closeSubpath: pointCount = 0
            @unknown default: hasFinitePoints = false; return
            }
            for index in 0..<pointCount {
                let point = element.points[index]
                hasFinitePoints = hasFinitePoints && point.x.isFinite && point.y.isFinite
            }
        }
        guard hasFinitePoints else { throw ShapePathError.invalidPath }
        guard style.lineWidth.isFinite, style.lineWidth >= 0,
              style.miterLimit.isFinite, style.miterLimit >= 0,
              style.dashPhase.isFinite,
              style.dash.allSatisfy({ $0.isFinite && $0 >= 0 }) else {
            throw ShapePathError.invalidStrokeStyle
        }
        let dashLength = style.dash.reduce(0, +)
        guard style.dash.isEmpty || (dashLength.isFinite && dashLength > 0) else {
            throw ShapePathError.invalidStrokeStyle
        }
        guard style.lineWidth > 0 else { return CGMutablePath() }

        let centerline: CGPath
        if style.dash.isEmpty {
            centerline = path
        } else {
            centerline = path.copy(dashingWithPhase: style.dashPhase, lengths: style.dash)
        }
        return centerline.copy(strokingWithWidth: style.lineWidth,
                               lineCap: style.lineCap,
                               lineJoin: style.lineJoin,
                               miterLimit: style.miterLimit)
    }

    /// Rounded bends use the same tangent-distance clamp as RoundedPath.
    static func roundedPolylinePath(points: [CGPoint], cornerRadius: CGFloat, closed: Bool) throws -> CGPath {
        guard points.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else {
            throw ShapePathError.invalidPath
        }
        guard cornerRadius.isFinite, cornerRadius >= 0 else {
            throw ShapePathError.invalidCornerRadius
        }

        var distinctPoints: [CGPoint] = []
        for point in points where point != distinctPoints.last {
            distinctPoints.append(point)
        }
        if closed, distinctPoints.count > 1, distinctPoints.first == distinctPoints.last {
            distinctPoints.removeLast()
        }
        let path = CGMutablePath()
        guard distinctPoints.count > 1 else { return path }
        if cornerRadius == 0 || distinctPoints.count < 3 {
            path.addLines(between: distinctPoints)
            if closed { path.closeSubpath() }
            return path
        }

        if !closed { path.move(to: distinctPoints[0]) }
        let indices = closed ? 0..<distinctPoints.count : 1..<(distinctPoints.count - 1)
        for index in indices {
            let point = distinctPoints[index]
            let previous = distinctPoints[(index + distinctPoints.count - 1) % distinctPoints.count]
            let next = distinctPoints[(index + 1) % distinctPoints.count]
            addRoundedBend(to: path, at: point, from: previous, to: next, radius: cornerRadius)
        }
        if closed {
            path.closeSubpath()
        } else {
            path.addLine(to: distinctPoints[distinctPoints.count - 1])
        }
        return path
    }

    private static func addRoundedBend(to path: CGMutablePath, at point: CGPoint,
                                       from previous: CGPoint, to next: CGPoint, radius: CGFloat) {
        let incoming = CGPoint(x: point.x - previous.x, y: point.y - previous.y)
        let outgoing = CGPoint(x: point.x - next.x, y: point.y - next.y)
        let incomingLength = hypot(incoming.x, incoming.y)
        let outgoingLength = hypot(outgoing.x, outgoing.y)
        let cross = (incoming.x / incomingLength) * (outgoing.y / outgoingLength)
            - (incoming.y / incomingLength) * (outgoing.x / outgoingLength)
        guard abs(cross) > 1e-12 else {
            if path.isEmpty { path.move(to: point) } else { path.addLine(to: point) }
            return
        }

        let halfAngle = (atan2(incoming.y, incoming.x) - atan2(outgoing.y, outgoing.x)) / 2
        let tangent = abs(tan(halfAngle))
        let segment = min(radius / tangent, min(incomingLength, outgoingLength))
        let roundedRadius = min(radius, segment * tangent)
        let leading = CGPoint(x: point.x - incoming.x * segment / incomingLength,
                              y: point.y - incoming.y * segment / incomingLength)
        let trailing = CGPoint(x: point.x - outgoing.x * segment / outgoingLength,
                               y: point.y - outgoing.y * segment / outgoingLength)
        let centerVector = CGPoint(x: point.x * 2 - leading.x - trailing.x,
                                   y: point.y * 2 - leading.y - trailing.y)
        let centerDistance = hypot(centerVector.x, centerVector.y)
        guard centerDistance > 0, roundedRadius.isFinite else {
            if path.isEmpty { path.move(to: point) } else { path.addLine(to: point) }
            return
        }
        let scale = hypot(segment, roundedRadius) / centerDistance
        let center = CGPoint(x: point.x - centerVector.x * scale, y: point.y - centerVector.y * scale)
        let startAngle = atan2(leading.y - center.y, leading.x - center.x)
        let endAngle = atan2(trailing.y - center.y, trailing.x - center.x)
        let sweep = endAngle - startAngle
        let clockwise = (sweep < 0) != (abs(sweep) > .pi)
        path.addArc(center: center, radius: roundedRadius,
                    startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
    }
}
