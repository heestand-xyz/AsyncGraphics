//
//  Sample.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/03.
//

import Foundation
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    enum SubPixelError: LocalizedError {
        case pixelLocationOutOfBounds
        var errorDescription: String? {
            switch self {
            case .pixelLocationOutOfBounds:
                "Sub pixel location is out of bounds."
            }
        }
    }

    /// Sample at a `location` coordinate, if the coordinate is fractional nearest pixels will be interpolated.
    ///
    /// Origin is at top left.
    public func subPixel(at location: CGPoint) async throws -> PixelColor {
        try await subPixel(x: location.x, y: location.y)
    }
    
    /// Sample at an `x` and `y` coordinate, if the coordinate is fractional nearest pixels will be interpolated.
    ///
    /// Origin is at top left.
    public func subPixel(x: CGFloat, y: CGFloat) async throws -> PixelColor {
        try await subPixel(u: x / (resolution.width - 1.0),
                           v: y / (resolution.height - 1.0))
    }

    /// Sample at relative `uv` coordinates
    ///
    /// `u` is horizontal, `v` is vertical, between `0.0` and `1.0`.
    ///
    /// Origin is at top left.
    public func subPixel(u: CGFloat, v: CGFloat) async throws -> PixelColor {
        guard u >= 0.0, u <= 1.0, v >= 0.0, v <= 1.0 else {
            throw SubPixelError.pixelLocationOutOfBounds
        }
        let uv = CGPoint(x: u, y: v)
        let location: CGPoint = uv * (resolution - 1.0) + 0.5
        let x = Int(location.x)
        let y = Int(location.y)
        if CGFloat(x) == location.x - 0.5,
           CGFloat(y) == location.y - 0.5 {
            return try await pixel(x: x, y: y)
        }
        let width = Int(resolution.width)
        let height = Int(resolution.height)
        let subPixelOffset: CGPoint = location - CGPoint(x: x, y: y)
        let topLeftPixelColor: PixelColor = try await pixel(x: x, y: y)
        let topRightPixelColor: PixelColor = x + 1 < width ? try await pixel(x: x + 1, y: y) : topLeftPixelColor
        let bottomLeftPixelColor: PixelColor = y + 1 < height ? try await pixel(x: x, y: y + 1) : topLeftPixelColor
        let bottomRightPixelColor: PixelColor = x + 1 < width && y + 1 < height ? try await pixel(x: x + 1, y: y + 1) : topLeftPixelColor
        let topPixelColor: PixelColor = topLeftPixelColor * (1.0 - subPixelOffset.x) + topRightPixelColor * subPixelOffset.x
        let bottomPixelColor: PixelColor = bottomLeftPixelColor * (1.0 - subPixelOffset.x) + bottomRightPixelColor * subPixelOffset.x
        return topPixelColor * (1.0 - subPixelOffset.y) + bottomPixelColor * subPixelOffset.y
    }
}
