import AsyncGraphics
import CoreGraphics
import PixelColor
import Testing

struct ParticleRenderingTests {

    @Test("Particles use source texel centers and the output aspect ratio")
    func positionsAndColors() async throws {
        let positions: Graphic = try .channels(
            [Float(-0.375), 0.125, 1, 1, 0.625, 0.125, 1, 1],
            resolution: CGSize(width: 2, height: 1)
        )
        let colors: Graphic = try .pixels([[.rawRed, .rawBlue]])
        let resolution = CGSize(width: 12, height: 4)

        let plain: Graphic = try await positions.uvParticles(backgroundColor: .clear, resolution: resolution)
        let colored: Graphic = try await positions.uvColorParticles(with: colors, backgroundColor: .clear, resolution: resolution)
        let plainPixels: [[PixelColor]] = try await plain.pixelColors
        let colorPixels: [[PixelColor]] = try await colored.pixelColors
        #expect(plainPixels[1][4].opacity == 1)
        #expect(plainPixels[1][8].opacity == 1)
        #expect(colorPixels[1][4].red == 1)
        #expect(colorPixels[1][8].blue == 1)
        #expect(colorPixels[1][8].red == 0)
    }

    @Test("Particle placement uses the allocated pixel dimensions for fractional output sizes")
    func fractionalOutputDimensions() async throws {
        let positions: Graphic = try .channels([Float(1.5), 0.25, 1, 1], resolution: CGSize(width: 1, height: 1))
        let colors: Graphic = try .pixels([[.rawBlue]])
        let requested = CGSize(width: 8, height: 2.9)
        let allocated = CGSize(width: 8, height: 2)

        let plain: Graphic = try await positions.uvParticles(backgroundColor: .clear, resolution: requested)
        let colored: Graphic = try await positions.uvColorParticles(with: colors, backgroundColor: .clear, resolution: requested)
        #expect(plain.resolution == allocated)
        #expect(colored.resolution == allocated)

        let plainPixels: [[PixelColor]] = try await plain.pixelColors
        let coloredPixels: [[PixelColor]] = try await colored.pixelColors
        // The particle is centered at (7, 0.5), on the boundary of the last two columns.
        #expect(plainPixels[0].suffix(2).contains(.white))
        #expect(coloredPixels[0].suffix(2).contains(.rawBlue))
    }
}
