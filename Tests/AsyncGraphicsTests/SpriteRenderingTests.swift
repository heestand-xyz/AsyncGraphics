import AsyncGraphics
import CoreGraphics
import Metal
import PixelColor
import Testing

struct SpriteRenderingTests {

    @Test("Single and array textures preserve sprite order after a zero scale")
    func textureBinding() async throws {
        let resolution = CGSize(width: 8, height: 8)
        let red: Graphic = try await .color(.rawRed, resolution: resolution)
        let blue: Graphic = try await .color(.rawBlue, resolution: resolution)
        let center = CGPoint(x: 4, y: 4)
        let sprites: [Graphic.Sprite] = [
            Graphic.Sprite(position: center, scale: .zero),
            Graphic.Sprite(position: center),
        ]
        let single: Graphic = try await .sprites(with: [red], sprites: sprites, resolution: resolution)
        let array: Graphic = try await .sprites(with: [red, blue], sprites: sprites, resolution: resolution)
        let singlePixels: [[PixelColor]] = try await single.pixelColors
        let arrayPixels: [[PixelColor]] = try await array.pixelColors
        #expect(singlePixels[4][4] == .rawRed)
        #expect(arrayPixels[4][4] == .rawBlue)
    }

    @Test("Empty sprite inputs preserve background channels and output format")
    func backgroundOnly() async throws {
        let resolution = CGSize(width: 2, height: 2)
        let background = PixelColor(red: 1.5, green: 0.5, blue: 0, opacity: 0.25)
        let source: Graphic = try await .color(.white, resolution: resolution)
        for graphics: [Graphic] in [[], [source]] {
            let output: Graphic = try await .sprites(
                with: graphics, sprites: [], backgroundColor: background,
                resolution: resolution, contentOptions: [.bit32, .displayP3]
            )
            #expect(output.bits == ._32)
            #expect(output.colorSpace == .displayP3)
            let color: PixelColor = try await output.firstPixelColor
            #expect(color == background)
        }
    }

    @Test("R8 sprites keep an opaque black border across the sampling padding")
    func opaqueClampToZeroBorder() async throws {
        let texture: MTLTexture = try singlePixelTexture(format: .r8Unorm, usage: .shaderRead, bytes: [255])
        let source: Graphic = try Graphic.texture(texture)
        let sprite = Graphic.Sprite(position: CGPoint(x: 4.5, y: 4.5))
        for graphics: [Graphic] in [[source], [source, source]] {
            let output: Graphic = try await Graphic.sprites(
                with: graphics, sprites: [sprite], backgroundColor: .white,
                resolution: CGSize(width: 8, height: 8)
            )
            let pixels: [[PixelColor]] = try await output.pixelColors
            #expect(pixels[4][4] == .rawRed)
            // The two border samples have u = -0.5 and -1.5. The padding is one texel.
            #expect(pixels[4][3] == .black)
            #expect(pixels[4][2] == .black)
        }
    }

    @Test("Sprites can sample a single render-target-only source through a copy")
    func renderTargetOnlySource() async throws {
        let texture: MTLTexture = try singlePixelTexture(format: .rgba8Unorm, usage: .renderTarget, bytes: [0, 0, 255, 255])
        let source: Graphic = try Graphic.texture(texture)
        let output: Graphic = try await Graphic.sprites(
            with: [source], sprites: [Graphic.Sprite(position: CGPoint(x: 0.5, y: 0.5))],
            resolution: CGSize(width: 1, height: 1)
        )
        let color: PixelColor = try await output.firstPixelColor
        #expect(color == .rawBlue)
    }

    @Test("Sprites preserve each source view's channel swizzle")
    func sourceTextureSwizzles() async throws {
        let redTexture: MTLTexture = try singlePixelTexture(
            format: .rgba8Unorm, usage: [.shaderRead, .pixelFormatView], bytes: [255, 0, 0, 255]
        )
        let blueView: MTLTexture = try #require(redTexture.makeTextureView(
            pixelFormat: .rgba8Unorm, textureType: .type2D, levels: 0..<1, slices: 0..<1,
            swizzle: MTLTextureSwizzleChannels(red: .blue, green: .green, blue: .red, alpha: .alpha)
        ))
        let blue: Graphic = try Graphic.texture(blueView)
        let red: Graphic = try Graphic.texture(redTexture)
        let resolution = CGSize(width: 4, height: 4)
        let left = Graphic.Sprite(position: CGPoint(x: 0.5, y: 1.5))
        let right = CGPoint(x: 2.5, y: 1.5)

        let single: Graphic = try await .sprites(with: [blue], sprites: [left], resolution: resolution)
        let singlePixels: [[PixelColor]] = try await single.pixelColors
        #expect(singlePixels[1][0] == .rawBlue)

        let hidden = Graphic.Sprite(position: right, scale: .zero)
        let copied: Graphic = try await .sprites(with: [blue, red], sprites: [left, hidden], resolution: resolution)
        let copiedPixels: [[PixelColor]] = try await copied.pixelColors
        #expect(copiedPixels[1][0] == .rawBlue)
        #expect(copiedPixels[1][2] == .clear)

        let mixed: Graphic = try await .sprites(with: [blue, red], sprites: [left, Graphic.Sprite(position: right)], resolution: resolution)
        let mixedPixels: [[PixelColor]] = try await mixed.pixelColors
        #expect(mixedPixels[1][0] == .rawBlue)
        #expect(mixedPixels[1][2] == .rawRed)
    }

    @Test("Fixed sprite placement uses allocated pixels for fractional output sizes")
    func fractionalFixedPlacement() async throws {
        let allocated = CGSize(width: 8, height: 2)
        let requested = CGSize(width: 8, height: 2.9)
        let source: Graphic = try await .color(.white, resolution: allocated)
        let center = CGPoint(x: requested.width / 2, y: requested.height / 2)
        let sprite = Graphic.Sprite(position: center, size: requested, placement: .fixed)
        let output: Graphic = try await .sprites(
            with: [source], sprites: [sprite], backgroundColor: .clear, resolution: requested
        )
        #expect(output.resolution == allocated)
        let pixels: [[PixelColor]] = try await output.pixelColors
        for row in pixels {
            #expect(row[3].opacity == 1)
            #expect(row[4].opacity == 1)
        }
    }

    // MARK: - Helpers

    private func singlePixelTexture(format: MTLPixelFormat, usage: MTLTextureUsage, bytes: [UInt8]) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: format, width: 1, height: 1, mipmapped: false)
        descriptor.usage = usage
#if os(macOS) && arch(x86_64)
        descriptor.storageMode = .managed
#else
        descriptor.storageMode = .shared
#endif
        let texture: MTLTexture = try #require(Renderer.metalDevice.makeTexture(descriptor: descriptor))
        texture.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0, withBytes: bytes, bytesPerRow: bytes.count)
        return texture
    }
}
