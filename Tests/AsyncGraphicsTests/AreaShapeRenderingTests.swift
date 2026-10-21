import AsyncGraphics
import CoreGraphics
import Foundation
import PixelColor
import SwiftUI
import Testing

@Suite("Area Shape Rendering", .serialized)
struct AreaShapeRenderingTests {
    private let resolution = CGSize(width: 32, height: 32)

    @Test("Empty and degenerate paths produce only the background")
    func emptyPaths() async throws {
        let pointSets: [[CGPoint]] = [[], [CGPoint(x: 8, y: 8)], [CGPoint(x: 8, y: 8), CGPoint(x: 24, y: 24)]]
        for points in pointSets {
            let graphic = try await Graphic.area(points: points, color: .white, backgroundColor: .clear,
                                                 resolution: resolution, options: .bit32)
            #expect(try alpha(graphic).allSatisfy { $0 == 0 })
        }
    }

    @Test("Winding and even-odd fill rules preserve nested contours")
    func nestedContours() async throws {
        let path = CGMutablePath()
        path.addRect(CGRect(x: 4, y: 4, width: 24, height: 24))
        path.addRect(CGRect(x: 12, y: 12, width: 8, height: 8))
        let winding = try await Graphic.path(path, fillRule: .winding, color: .white, backgroundColor: .clear,
                                             resolution: resolution, options: .bit32)
        let evenOdd = try await Graphic.path(path, fillRule: .evenOdd, color: .white, backgroundColor: .clear,
                                             resolution: resolution, options: .bit32)
        #expect(try alpha(winding)[16 * 32 + 16] == 1)
        #expect(try alpha(evenOdd)[16 * 32 + 16] == 0)
        #expect(try alpha(evenOdd)[8 * 32 + 8] == 1)
    }

    @Test("Closed strokes keep their interior hole")
    func strokeHole() async throws {
        let path = CGPath(rect: CGRect(x: 8, y: 8, width: 16, height: 16), transform: nil)
        let graphic = try await Graphic.path(path, stroke: .init(lineWidth: 4),
                                             color: .white, backgroundColor: .clear,
                                             resolution: resolution, options: .bit32)
        let coverage = try alpha(graphic)
        #expect(coverage[16 * 32 + 8] == 1)
        #expect(coverage[16 * 32 + 16] == 0)
    }

    @Test("Subpixel path strokes preserve quarter-pixel coverage")
    func thinStroke() async throws {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 4, y: 16))
        path.addLine(to: CGPoint(x: 28, y: 16))
        let graphic = try await Graphic.path(path, stroke: .init(lineWidth: 0.25),
                                             color: .white, backgroundColor: .clear,
                                             resolution: resolution, options: .bit32)
        let coverage = try alpha(graphic)
        let total = (0..<32).reduce(Float.zero) { $0 + coverage[$1 * 32 + 16] }
        #expect(abs(total - 0.25) < 0.0001)
    }

    @Test("Thin strokes between sample-grid positions retain their exact area")
    func thinStrokeBetweenSamples() async throws {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 4, y: 16.5))
        path.addLine(to: CGPoint(x: 28, y: 16.5))
        let graphic = try await Graphic.path(path, stroke: .init(lineWidth: 0.1),
                                             color: .white, backgroundColor: .clear,
                                             resolution: resolution, options: .bit32)
        let coverage = try alpha(graphic)
        let total = (0..<32).reduce(Float.zero) { $0 + coverage[$1 * 32 + 16] }
        #expect(abs(total - 0.1) < 0.0001)
    }

    @Test("Area segment buffers are not truncated to the renderer's default array limit")
    func largeSegmentBuffer() async throws {
        let points = (0..<257).map { index in
            let angle = CGFloat(index) / 257 * .pi * 2
            return CGPoint(x: 16 + cos(angle) * 12, y: 16 + sin(angle) * 12)
        }
        let graphic = try await Graphic.area(points: points, color: .white, backgroundColor: .clear,
                                             resolution: resolution, options: [.bit32, .pixelated])
        let coverage = try alpha(graphic)
        #expect(coverage[16 * 32 + 16] == 1)
        #expect(coverage[16 * 32 + 5] == 1)
        #expect(coverage[5 * 32 + 16] == 1)
        #expect(coverage[0] == 0)
        #expect(coverage.allSatisfy { $0 == 0 || $0 == 1 })
    }

    @Test("Polygon rotation retains its public negative-clockwise convention")
    func polygonRotation() async throws {
        let rotation = 0.3
        let position = CGPoint(x: 16.2, y: 16.1)
        let points = (0..<5).map { index in
            let angle = CGFloat(index) / 5 * .pi * 2 - CGFloat(rotation)
            return CGPoint(x: position.x + sin(angle) * 11, y: position.y - cos(angle) * 11)
        }
        let polygon = try await Graphic.polygon(count: 5, radius: 11, position: position, rotation: .radians(rotation),
                                                color: .white, backgroundColor: .clear,
                                                resolution: resolution, options: [.bit32, .pixelated])
        let area = try await Graphic.area(points: points, color: .white, backgroundColor: .clear,
                                          resolution: resolution, options: [.bit32, .pixelated])
        #expect(try alpha(polygon) == alpha(area))
    }

    @Test("Fully rounded polygons saturate at their inscribed circle")
    func polygonRoundingSaturation() async throws {
        let apothem = CGFloat(11) * cos(.pi / 5)
        let polygon = try await Graphic.polygon(count: 5, radius: 11, cornerRadius: 100,
                                                color: .white, backgroundColor: .clear,
                                                resolution: resolution, options: [.bit32, .pixelated])
        let circle = try await Graphic.circle(radius: apothem, color: .white, backgroundColor: .clear,
                                              resolution: resolution, options: [.bit32, .pixelated])
        #expect(try alpha(polygon) == alpha(circle))
    }

    @Test("Inverted star radii preserve the original half-step rotation")
    func invertedStarRadii() async throws {
        let inverted = try await Graphic.star(count: 5, innerRadius: 11, outerRadius: 5,
                                               color: .white, backgroundColor: .clear,
                                               resolution: resolution, options: [.bit32, .pixelated])
        let rotated = try await Graphic.star(count: 5, innerRadius: 5, outerRadius: 11, rotation: .radians(.pi / 5),
                                              color: .white, backgroundColor: .clear,
                                              resolution: resolution, options: [.bit32, .pixelated])
        #expect(try alpha(inverted) == alpha(rotated))
    }

    @Test("Low point counts retain the public polygon and star behavior")
    func lowPointCounts() async throws {
        let polygon = try await Graphic.polygon(count: 2, radius: 11,
                                                color: .white, backgroundColor: .clear,
                                                resolution: resolution, options: [.bit32, .pixelated])
        #expect(try alpha(polygon).allSatisfy { $0 == 0 })
        let star = try await Graphic.star(count: 2, innerRadius: 5, outerRadius: 11,
                                          color: .white, backgroundColor: .clear,
                                          resolution: resolution, options: [.bit32, .pixelated])
        let diamond = try await Graphic.area(points: [CGPoint(x: 16, y: 5), CGPoint(x: 21, y: 16),
                                                       CGPoint(x: 16, y: 27), CGPoint(x: 11, y: 16)],
                                             color: .white, backgroundColor: .clear,
                                             resolution: resolution, options: [.bit32, .pixelated])
        #expect(try alpha(star) == alpha(diamond))
    }

    @Test("Area coverage interpolates premultiplied translucent colors")
    func translucentArea() async throws {
        let points = [CGPoint(x: 8.25, y: 8.25), CGPoint(x: 24.25, y: 8.25),
                      CGPoint(x: 24.25, y: 24.25), CGPoint(x: 8.25, y: 24.25)]
        let graphic = try await Graphic.area(points: points, color: PixelColor(red: 1, green: 0.25, blue: 0, opacity: 0.5),
                                             backgroundColor: .clear, resolution: resolution, options: .bit32)
        let pixels = try graphic.channels32
        var partialPixels = 0
        for index in stride(from: 0, to: pixels.count, by: 4) {
            let opacity = pixels[index + 3]
            if opacity > 0 && opacity < 0.5 { partialPixels += 1 }
            #expect(abs(pixels[index] - opacity) < 0.0001)
            #expect(abs(pixels[index + 1] - opacity * 0.25) < 0.0001)
        }
        #expect(partialPixels > 0)
    }

    private func alpha(_ graphic: Graphic) throws -> [Float] {
        let pixels = try graphic.channels32
        return stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }
    }
}
