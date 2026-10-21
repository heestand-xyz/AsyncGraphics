//
//  Created by Anton Heestand on 2023-04-26.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    public static func star(count: Int,
                            innerRadius: CGFloat? = nil,
                            outerRadius: CGFloat? = nil,
                            position: CGPoint? = nil,
                            rotation: Angle = .zero,
                            cornerRadius: CGFloat = 0.0,
                            stroke: StrokeStyle? = nil,
                            color: PixelColor = .white,
                            backgroundColor: PixelColor = .black,
                            resolution: CGSize,
                            tile: Tile = .one,
                            options: ContentOptions = []) async throws -> Graphic {
        
        let outerRadius: CGFloat = outerRadius ?? min(resolution.width, resolution.height) / 2
        let innerRadius: CGFloat = innerRadius ?? (outerRadius / 2)
        let position: CGPoint = position ?? (resolution.asPoint / 2)
        guard innerRadius.isFinite, outerRadius.isFinite,
              position.x.isFinite, position.y.isFinite,
              rotation.radians.isFinite else {
            throw ShapePathError.invalidPath
        }
        guard cornerRadius.isFinite else { throw ShapePathError.invalidCornerRadius }
        let count = max(count, 0)
        guard count <= 32_768 else { throw ShapePathError.excessiveComplexity }
        let contour = CGMutablePath()
        if count > 0, innerRadius >= 0, outerRadius >= 0, max(innerRadius, outerRadius) > 0 {
            let largeRadius = max(innerRadius, outerRadius)
            let smallRadius = min(innerRadius, outerRadius)
            // The public API also permits inverted radii. Preserve its half-step
            // rotation so the supplied outer radius continues to point upwards.
            let offset: CGFloat = outerRadius >= innerRadius ? 0 : 0.5
            let radians = CGFloat(rotation.radians.truncatingRemainder(dividingBy: .pi * 2))
            func point(_ index: CGFloat, radius: CGFloat) -> CGPoint {
                let angle = (index + offset) / CGFloat(count) * .pi * 2 + radians
                return CGPoint(x: position.x + sin(angle) * radius,
                               y: position.y - cos(angle) * radius)
            }
            if cornerRadius <= 0 {
                contour.move(to: point(-0.5, radius: smallRadius))
                for index in 0..<count {
                    contour.addLine(to: point(CGFloat(index), radius: largeRadius))
                    contour.addLine(to: point(CGFloat(index) + 0.5, radius: smallRadius))
                }
            } else {
                let isSubConvex = smallRadius > largeRadius * cos(.pi / CGFloat(count))
                for index in 0..<count {
                    let previous = point(CGFloat(index) - 0.5, radius: smallRadius)
                    let outer = point(CGFloat(index), radius: largeRadius)
                    let inner = point(CGFloat(index) + 0.5, radius: smallRadius)
                    let next = point(CGFloat(index) + 1, radius: largeRadius)
                    addStarCorner(to: contour, at: outer, from: previous, to: inner,
                                  radius: cornerRadius, clockwise: false)
                    addStarCorner(to: contour, at: inner, from: outer, to: next,
                                  radius: cornerRadius, clockwise: !isSubConvex)
                }
            }
            contour.closeSubpath()
        }
        return try await path(contour, stroke: stroke, color: color, backgroundColor: backgroundColor,
                              resolution: resolution, tile: tile, options: options)
    }

    private static func addStarCorner(to path: CGMutablePath, at point: CGPoint,
                                      from previous: CGPoint, to next: CGPoint,
                                      radius: CGFloat, clockwise: Bool) {
        let incoming = CGPoint(x: point.x - previous.x, y: point.y - previous.y)
        let outgoing = CGPoint(x: point.x - next.x, y: point.y - next.y)
        let incomingLength = hypot(incoming.x, incoming.y)
        let outgoingLength = hypot(outgoing.x, outgoing.y)
        let cross = incoming.x * outgoing.y - incoming.y * outgoing.x
        guard incomingLength > 0, outgoingLength > 0,
              abs(cross / incomingLength / outgoingLength) > 1e-12 else {
            if path.isEmpty { path.move(to: point) } else { path.addLine(to: point) }
            return
        }
        let halfAngle = (atan2(incoming.y, incoming.x) - atan2(outgoing.y, outgoing.x)) / 2
        let tangent = abs(tan(halfAngle))
        let segment = min(radius / tangent, min(incomingLength, outgoingLength))
        let fittedRadius = min(radius, segment * tangent)
        let leading = CGPoint(x: point.x - incoming.x * segment / incomingLength,
                              y: point.y - incoming.y * segment / incomingLength)
        let trailing = CGPoint(x: point.x - outgoing.x * segment / outgoingLength,
                               y: point.y - outgoing.y * segment / outgoingLength)
        let centerVector = CGPoint(x: point.x * 2 - leading.x - trailing.x,
                                   y: point.y * 2 - leading.y - trailing.y)
        let centerDistance = hypot(centerVector.x, centerVector.y)
        guard centerDistance > 0 else {
            if path.isEmpty { path.move(to: point) } else { path.addLine(to: point) }
            return
        }
        let scale = hypot(segment, fittedRadius) / centerDistance
        let center = CGPoint(x: point.x - centerVector.x * scale,
                             y: point.y - centerVector.y * scale)
        // Shapes.Star fits the circle center to the adjacent edges but retains
        // the requested arc radius, including its large-rounding behavior.
        path.addArc(center: center, radius: radius,
                    startAngle: atan2(leading.y - center.y, leading.x - center.x),
                    endAngle: atan2(trailing.y - center.y, trailing.x - center.x),
                    clockwise: clockwise)
    }
}
