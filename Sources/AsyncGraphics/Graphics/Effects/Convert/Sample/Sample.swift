//
//  Sample.swift
//  AsyncGraphics
//
//  Created by a-heestand on 2025/01/03.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {

    /// Sample at relative `uv` coordinates
    ///
    /// `u` is horizontal, `v` is vertical, from top left, between `0.0` and `1.0`
    public func subPixel(u: CGFloat, v: CGFloat) async throws -> PixelColor {
        let width = Int(resolution.width)
        let height = Int(resolution.height)
        let uv = CGPoint(x: min(1.0, max(0.0, u)),
                         y: min(1.0, max(0.0, v)))
        let location: CGPoint = uv * resolution
        let x = Int(location.x)
        let y = Int(location.y)
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
