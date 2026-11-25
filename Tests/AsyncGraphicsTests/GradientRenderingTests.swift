import AsyncGraphics
import CoreGraphics
import PixelColor
import Testing

struct GradientRenderingTests {

    @Test("Gradient interpolates unsorted stops beyond the seventh entry")
    func laterStopInterpolation() async throws {
        var stops: [Graphic.GradientStop] = [
            Graphic.GradientStop(at: 1, color: .black),
            Graphic.GradientStop(at: 0, color: .black),
        ]
        for index in 1...5 {
            stops.append(Graphic.GradientStop(at: CGFloat(index) / 16, color: .black))
        }
        stops.append(Graphic.GradientStop(at: 0.75, color: .rawRed))

        let gradient: Graphic = try await .gradient(
            direction: .horizontal, stops: stops,
            resolution: CGSize(width: 4, height: 1), options: .bit32
        )
        // The last pixel center is at 0.875, halfway from red to black.
        let pixels: [[PixelColor]] = try await gradient.pixelColors
        #expect(abs(pixels[0][3].red - 0.5) < 0.001)
        #expect(pixels[0][3].opacity == 1)
    }
}
