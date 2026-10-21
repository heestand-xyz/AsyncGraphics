import AsyncGraphics
import CoreGraphics
import Foundation
import PixelColor
import SwiftUI
import Testing

@Suite("Primitive Shape Rendering", .serialized)
struct PrimitiveShapeRenderingTests {
    private let resolution = CGSize(width: 32, height: 32)

    @Test("Rectangle antialiases fractional straight edges")
    func rectangleStraightEdges() async throws {
        let graphic = try await Graphic.rectangle(
            frame: CGRect(x: 8.25, y: 8.25, width: 16, height: 16),
            color: .white, backgroundColor: .clear, resolution: resolution, options: .bit32
        )
        let pixels = try graphic.channels32
        for (x, y) in [(8, 16), (24, 16), (16, 8), (16, 24)] {
            let alpha = pixels[(y * 32 + x) * 4 + 3]
            #expect(alpha > 0 && alpha < 1)
        }
        #expect(pixels[(16 * 32 + 16) * 4 + 3] == 1)
        #expect(pixels[3] == 0)
    }

    @Test("Circle coverage is independent of canvas aspect ratio")
    func circleAspectRatio() async throws {
        let position = CGPoint(x: 16.2, y: 16.1)
        let square = try await Graphic.circle(
            radius: 7.3, position: position, color: .white, backgroundColor: .clear,
            resolution: resolution, options: .bit32
        )
        let wide = try await Graphic.circle(
            radius: 7.3, position: position, color: .white, backgroundColor: .clear,
            resolution: CGSize(width: 64, height: 32), options: .bit32
        )
        let squarePixels = try square.channels32
        let widePixels = try wide.channels32
        var maximumDifference: Float = 0
        for y in 0..<32 {
            for x in 0..<32 {
                let squareAlpha = squarePixels[(y * 32 + x) * 4 + 3]
                let wideAlpha = widePixels[(y * 64 + x) * 4 + 3]
                maximumDifference = max(maximumDifference, abs(squareAlpha - wideAlpha))
            }
        }
        #expect(maximumDifference < 0.0001)
    }

    @Test("Arc antialiases angular cuts inside the circular boundary")
    func arcAngularEdges() async throws {
        let graphic = try await Graphic.arc(
            angle: .zero, length: .degrees(90), radius: 10,
            color: .white, backgroundColor: .clear, resolution: resolution, options: .bit32
        )
        let pixels = try graphic.channels32
        var partialPixels = 0
        for y in 0..<32 {
            for x in 0..<32 {
                let distance = hypot(Double(x) + 0.5 - 16, Double(y) + 0.5 - 16)
                let alpha = pixels[(y * 32 + x) * 4 + 3]
                if (3...8).contains(distance), alpha > 0, alpha < 1 {
                    partialPixels += 1
                }
            }
        }
        #expect(partialPixels > 0)
    }

    @Test("Pixelated primitives keep binary coverage", arguments: [0, 1, 2])
    func pixelatedCoverage(primitive: Int) async throws {
        let graphic = try await primitiveGraphic(primitive, options: [.bit32, .pixelated])
        let pixels = try graphic.channels32
        let alpha = stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }
        #expect(alpha.contains(0))
        #expect(alpha.contains(1))
        #expect(alpha.allSatisfy { $0 == 0 || $0 == 1 })
    }

    @Test("Coverage colors are premultiplied once and pure alpha preserves hidden RGB")
    func translucentCoverage() async throws {
        let foreground = PixelColor(red: 1, green: 0.25, blue: 0.125, opacity: 0.5)
        let premultiplied = try await Graphic.circle(
            radius: 7.3, position: CGPoint(x: 16.2, y: 16.1),
            color: foreground, backgroundColor: .clear, resolution: resolution, options: .bit32
        )
        let straight = try await Graphic.circle(
            radius: 7.3, position: CGPoint(x: 16.2, y: 16.1),
            color: foreground, backgroundColor: .clear, resolution: resolution,
            options: [.bit32, .pureAlpha, .pureTranslucentColor]
        )
        let premultipliedPixels = try premultiplied.channels32
        let straightPixels = try straight.channels32
        var partialPixels = 0
        for index in stride(from: 0, to: premultipliedPixels.count, by: 4) {
            let alpha = premultipliedPixels[index + 3]
            if alpha > 0 && alpha < 0.5 {
                partialPixels += 1
            }
            #expect(abs(premultipliedPixels[index] - alpha) < 0.0001)
            #expect(abs(premultipliedPixels[index + 1] - alpha * 0.25) < 0.0001)
            #expect(abs(premultipliedPixels[index + 2] - alpha * 0.125) < 0.0001)
            #expect(abs(straightPixels[index + 3] - alpha) < 0.0001)
            #expect(abs(straightPixels[index] - 1) < 0.0001)
            #expect(abs(straightPixels[index + 1] - 0.25) < 0.0001)
            #expect(abs(straightPixels[index + 2] - 0.125) < 0.0001)
        }
        #expect(partialPixels > 0)
    }

    @Test("Subpixel rectangle strokes preserve their coverage")
    func thinRectangleStroke() async throws {
        let graphic = try await Graphic.strokedRectangle(
            frame: CGRect(x: 8.25, y: 8.25, width: 16, height: 16), lineWidth: 0.25,
            color: .white, backgroundColor: .clear, resolution: resolution, options: .bit32
        )
        let pixels = try graphic.channels32
        var rowCoverage: Float = 0
        for x in 0..<32 {
            rowCoverage += pixels[(16 * 32 + x) * 4 + 3]
        }
        #expect(abs(rowCoverage - 0.5) < 0.0001)
    }

    @Test("Subpixel fills survive symmetric derivative samples")
    func tinyFilledShapes() async throws {
        let rectangle = try await Graphic.rectangle(
            frame: CGRect(x: 8, y: 14.9, width: 16, height: 0.2),
            color: .white, backgroundColor: .clear, resolution: resolution, options: .bit32
        )
        let rectanglePixels = try rectangle.channels32
        var columnCoverage: Float = 0
        for y in 0..<32 {
            columnCoverage += rectanglePixels[(y * 32 + 16) * 4 + 3]
        }
        #expect(abs(columnCoverage - 0.2) < 0.0001)

        let circle = try await Graphic.circle(
            radius: 0.25, position: CGPoint(x: 15, y: 15),
            color: .white, backgroundColor: .clear, resolution: resolution, options: .bit32
        )
        let circlePixels = try circle.channels32
        let maximumAlpha = stride(from: 3, to: circlePixels.count, by: 4).map { circlePixels[$0] }.max() ?? 0
        #expect(maximumAlpha > 0 && maximumAlpha < 1)
    }

    @Test("Subpixel circle strokes do not become opaque")
    func thinCircleStroke() async throws {
        let graphic = try await Graphic.strokedCircle(
            radius: 8, lineWidth: 0.2, color: .white, backgroundColor: .clear,
            resolution: resolution, options: .bit32
        )
        let pixels = try graphic.channels32
        let maximumAlpha = stride(from: 3, to: pixels.count, by: 4).map { pixels[$0] }.max() ?? 0
        #expect(maximumAlpha > 0)
        #expect(maximumAlpha <= 0.21)
    }

    @Test("Sharp rectangle strokes retain mitered corners")
    func rectangleStrokeCorners() async throws {
        let graphic = try await Graphic.strokedRectangle(
            frame: CGRect(x: 8, y: 8, width: 16, height: 16), lineWidth: 4,
            color: .white, backgroundColor: .clear, resolution: resolution, options: [.bit32, .pixelated]
        )
        let pixels = try graphic.channels32
        #expect(pixels[(6 * 32 + 6) * 4 + 3] == 1)
        #expect(pixels[(16 * 32 + 16) * 4 + 3] == 0)
    }

    @Test("Filled arcs remain sectors and stroked arcs remain ring segments")
    func arcFillAndStroke() async throws {
        let filled = try await Graphic.arc(
            angle: .zero, length: .degrees(180), radius: 8,
            color: .white, backgroundColor: .clear, resolution: resolution, options: [.bit32, .pixelated]
        )
        let stroked = try await Graphic.strokedArc(
            angle: .zero, length: .degrees(180), radius: 8, lineWidth: 4,
            color: .white, backgroundColor: .clear, resolution: resolution, options: [.bit32, .pixelated]
        )
        let filledPixels = try filled.channels32
        let strokedPixels = try stroked.channels32
        #expect(filledPixels[(16 * 32 + 20) * 4 + 3] == 1)
        #expect(strokedPixels[(16 * 32 + 20) * 4 + 3] == 0)
        #expect(strokedPixels[(16 * 32 + 24) * 4 + 3] == 1)
        #expect(strokedPixels[(16 * 32 + 8) * 4 + 3] == 0)
    }

    private func primitiveGraphic(_ primitive: Int, options: Graphic.ContentOptions) async throws -> Graphic {
        switch primitive {
        case 0:
            return try await .circle(
                radius: 7.3, position: CGPoint(x: 16.2, y: 16.1),
                color: .white, backgroundColor: .clear, resolution: resolution, options: options
            )
        case 1:
            return try await .rectangle(
                frame: CGRect(x: 8.25, y: 8.25, width: 16, height: 16), cornerRadius: 3,
                color: .white, backgroundColor: .clear, resolution: resolution, options: options
            )
        default:
            return try await .arc(
                angle: .degrees(15), length: .degrees(130), radius: 10,
                color: .white, backgroundColor: .clear, resolution: resolution, options: options
            )
        }
    }
}
