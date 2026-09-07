import Foundation
import Metal
import PixelColor
import TextureMap
import Testing
@testable import AsyncGraphics

@MainActor
@Suite("Graphic Layer Rendering")
struct GraphicLayerRenderingTests {
    @Test("GraphicMetalLayer: Nearest sampling preserves orientation, pixels and alpha")
    func nearestSampling() async throws {
        let source = try Graphic.pixels([
            [PixelColor(red: 1, green: 0, blue: 0, opacity: 1), PixelColor(red: 0, green: 1, blue: 0, opacity: 1)],
            [PixelColor(red: 0, green: 0, blue: 1, opacity: 1), PixelColor(red: 0, green: 0, blue: 0, opacity: 0)],
        ], options: .bit32).assignColorSpace(.linearDisplayP3)
        let pixels = try await render(source, width: 4, height: 4, interpolate: false)
        for y in 0..<4 {
            for x in 0..<4 {
                let expected: [Float] = switch (x / 2, y / 2) {
                case (0, 0): [1, 0, 0, 1]
                case (1, 0): [0, 1, 0, 1]
                case (0, 1): [0, 0, 1, 1]
                default: [0, 0, 0, 0]
                }
                for channel in 0..<4 {
                    #expect(abs(pixels[(y * 4 + x) * 4 + channel] - expected[channel]) < 0.001)
                }
            }
        }
    }

    @Test("GraphicMetalLayer: Linear sampling blends neighboring pixels")
    func linearSampling() async throws {
        let source = try Graphic.pixels([
            [PixelColor(red: 1, green: 0, blue: 0, opacity: 1), PixelColor(red: 0, green: 1, blue: 0, opacity: 1)],
        ], options: .bit32).assignColorSpace(.linearDisplayP3)
        let pixels = try await render(source, width: 4, height: 1, interpolate: true)
        #expect(abs(pixels[4] - 0.75) < 0.001)
        #expect(abs(pixels[5] - 0.25) < 0.001)
        #expect(abs(pixels[8] - 0.25) < 0.001)
        #expect(abs(pixels[9] - 0.75) < 0.001)
    }

    @Test("GraphicMetalLayer: XDR distinguishes white from values above white", arguments: [TMColorSpace.linearSRGB, .nonLinearSRGB, .linearDisplayP3])
    func extendedWhite(colorSpace: TMColorSpace) async throws {
        let source = try Graphic.pixels([
            [PixelColor(red: 1, green: 1, blue: 1, opacity: 1), PixelColor(red: 2, green: 2, blue: 2, opacity: 1)],
        ], options: .bit32).assignColorSpace(colorSpace)
        let pixels = try await render(source, width: 2, height: 1, interpolate: false)
        for channel in 0..<3 {
            #expect(abs(pixels[channel] - 1) < 0.02)
            #expect(pixels[4 + channel] > 1.8)
            if colorSpace != .nonLinearSRGB {
                #expect(abs(pixels[4 + channel] - 2) < 0.02)
            }
        }
    }

    @Test("GraphicLayerColorConversion: Reuses storage while updating the converted frame")
    func conversionReuse() async throws {
        let conversion = GraphicLayerColorConversion()
        let first = try Graphic.pixels([[PixelColor(red: 1, green: 1, blue: 1, opacity: 1)]], options: .bit32)
            .assignColorSpace(.linearSRGB)
        let second = try Graphic.pixels([[PixelColor(red: 2, green: 2, blue: 2, opacity: 1)]], options: .bit32)
            .assignColorSpace(.linearSRGB)
        let queue = GraphicMetalLayerResources.shared.commandQueue
        let firstBuffer = try #require(queue.makeCommandBuffer())
        let firstTexture = conversion.texture(for: first, extendedDynamicRange: true, commandBuffer: firstBuffer)
        try await complete(firstBuffer)
        let secondBuffer = try #require(queue.makeCommandBuffer())
        let secondTexture = conversion.texture(for: second, extendedDynamicRange: true, commandBuffer: secondBuffer)
        #expect(firstTexture === secondTexture)
        try await complete(secondBuffer)
        let prepared = Graphic(name: "Converted", texture: secondTexture, bits: ._32, colorSpace: .linearDisplayP3)
        let pixels = try await render(prepared, width: 1, height: 1, interpolate: false)
        #expect(abs(pixels[0] - 2) < 0.02)
    }

    // MARK: - Helpers

    private func render(_ graphic: Graphic, width: Int, height: Int, interpolate: Bool) async throws -> [Float] {
        let resources = GraphicMetalLayerResources.shared
        let buffer = try #require(resources.commandQueue.makeCommandBuffer())
        let conversion = GraphicLayerColorConversion()
        let source = conversion.texture(for: graphic, extendedDynamicRange: true, commandBuffer: buffer)
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float, width: width, height: height, mipmapped: false)
        textureDescriptor.storageMode = .shared
        textureDescriptor.usage = .renderTarget
        let target = try #require(Renderer.metalDevice.makeTexture(descriptor: textureDescriptor))
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = target
        descriptor.colorAttachments[0].loadAction = .dontCare
        descriptor.colorAttachments[0].storeAction = .store
        let encoder = try #require(buffer.makeRenderCommandEncoder(descriptor: descriptor))
        encoder.setRenderPipelineState(resources.extendedPipeline)
        encoder.setFragmentTexture(source, index: 0)
        encoder.setFragmentSamplerState(interpolate ? resources.linearSampler : resources.nearestSampler, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        try await complete(buffer)
        var pixels = [Float16](repeating: 0, count: width * height * 4)
        pixels.withUnsafeMutableBytes { bytes in
            target.getBytes(bytes.baseAddress!, bytesPerRow: width * 4 * MemoryLayout<Float16>.stride,
                            from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        }
        return pixels.map { Float($0) }
    }

    private func complete(_ buffer: MTLCommandBuffer) async throws {
        await withCheckedContinuation { continuation in
            buffer.addCompletedHandler { _ in continuation.resume() }
            buffer.commit()
        }
        #expect(buffer.status == .completed)
        if let error = buffer.error { throw error }
    }
}
