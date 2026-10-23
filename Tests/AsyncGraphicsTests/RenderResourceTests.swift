import CoreGraphics
import Foundation
@preconcurrency import Metal
import PixelColor
import Spatial
import Testing
import TextureMap
@testable import AsyncGraphics

@Suite("Renderer Resource Preparation")
struct RenderResourceTests {

    @Test("Each preparation observes the current policy and preserves cache behavior")
    @RenderActor
    func optimizationSnapshots() throws {
        let originalOptimization = Renderer.optimization
        let originalPipelines = Renderer.storedRenderPipelines
        let originalComputePipelines = Renderer.storedComputePipelines
        defer {
            Renderer.optimization = originalOptimization
            Renderer.storedRenderPipelines = originalPipelines
            Renderer.storedComputePipelines = originalComputePipelines
        }
        Renderer.storedRenderPipelines = [:]
        Renderer.storedComputePipelines = [:]

        Renderer.optimization = .all
        let first = try resources()
        let cached = try resources()
        let firstSampler = try #require(first.sampler)
        let cachedSampler = try #require(cached.sampler)
        #expect(first.optimization == .all)
        #expect(try renderPipeline(first) === renderPipeline(cached))
        #expect(firstSampler === cachedSampler)
        #expect(Renderer.storedRenderPipelines.count == 1)

        Renderer.optimization = []
        let uncached = try resources(shader: .custom(fragment: "fragmentPassthrough", vertex: "vertexPassthrough"))
        let uncachedCompute = try resources(shader: .name("color3d"), is3D: true)
        #expect(uncached.optimization.isEmpty)
        #expect(uncachedCompute.optimization.isEmpty)
        #expect(Renderer.storedRenderPipelines.count == 1)
        #expect(Renderer.storedComputePipelines.isEmpty)

        Renderer.optimization = .all
        let restored = try resources()
        let compute = try resources(shader: .name("color3d"), is3D: true)
        let cachedCompute = try resources(shader: .name("color3d"), is3D: true)
        #expect(try renderPipeline(first) === renderPipeline(restored))
        #expect(try computePipeline(compute) === computePipeline(cachedCompute))
        #expect(Renderer.storedComputePipelines.count == 1)
        // Previously returned resources retain the policy for their own pass.
        #expect(uncached.optimization.isEmpty)
    }

    @Test("Queue acquisition uses the supplied pass policy")
    func queuePolicy() async throws {
        let uncached = await Renderer.useCommandQueue(optimization: [])
        #expect(uncached.0 == nil)
        #expect(uncached.1 != nil)

        let cached = await Renderer.useCommandQueue(optimization: .cacheCommandQueue)
        let lease = try #require(cached.0)
        #expect(cached.1 != nil)
        await Renderer.usedCommandQueue(id: lease)
    }

    @Test("A matching recycled texture is claimed once, with source replacement taking precedence")
    @RenderActor
    func recycledTextureOwnership() throws {
        let originalRecycleGraphic = Renderer.recycleGraphic
        defer { Renderer.recycleGraphic = originalRecycleGraphic }
        let graphic = try recyclableGraphic()
        Renderer.recycleGraphic = graphic

        let wrongSize = try resources(recycleResolution: CGSize(width: 9, height: 8))
        let wrongBits = try resources(bits: ._32, recycleResolution: graphic.resolution)
        let volume = try resources(shader: .name("color3d"), is3D: true)
        var replaceOptions = Renderer.Options()
        replaceOptions.targetSourceTexture = true
        let replacement = try resources(recycleResolution: graphic.resolution, options: replaceOptions)
        #expect(wrongSize.recycledTexture == nil)
        #expect(wrongBits.recycledTexture == nil)
        #expect(volume.recycledTexture == nil)
        #expect(replacement.recycledTexture == nil)
        #expect(Renderer.recycleGraphic?.id == graphic.id)

        let first = try resources(recycleResolution: graphic.resolution)
        let second = try resources(recycleResolution: graphic.resolution)
        #expect(try #require(first.recycledTexture) === graphic.texture)
        #expect(second.recycledTexture == nil)
        #expect(Renderer.recycleGraphic == nil)
    }

    @Test("A failed pipeline preparation leaves the recycled texture available")
    @RenderActor
    func failedPreparation() throws {
        let originalRecycleGraphic = Renderer.recycleGraphic
        defer { Renderer.recycleGraphic = originalRecycleGraphic }
        let graphic = try recyclableGraphic()
        Renderer.recycleGraphic = graphic

        #expect(throws: Renderer.RendererError.self) {
            try resources(shader: .name("missing-resource-test-shader"), recycleResolution: graphic.resolution)
        }
        #expect(Renderer.recycleGraphic?.id == graphic.id)
        let recovered = try resources(recycleResolution: graphic.resolution)
        #expect(try #require(recovered.recycledTexture) === graphic.texture)
    }

    @Test("Concurrent 2D and 3D passes retain their own resources and completed output")
    func concurrentRendering() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<8 {
                group.addTask {
                    let red = CGFloat(index) / 10.0
                    let color = PixelColor(red: red, green: 0.25, blue: 0.75)
                    let image = try await Graphic.color(color, resolution: CGSize(width: 8, height: 8), options: .bit32)
                    let invertedImage = try await image.inverted()
                    let pixels = try await invertedImage.pixelColors
                    #expect(abs(pixels[4][4].red - (1.0 - red)) < 0.001)
                    #expect(abs(pixels[4][4].green - 0.75) < 0.001)

                    let volume = try await Graphic3D.color(color, resolution: Size3D(width: 4, height: 4, depth: 4), options: .bit32)
                    let invertedVolume = try await volume.inverted()
                    let voxels = try await invertedVolume.voxelColors
                    #expect(abs(voxels[2][2][2].red - (1.0 - red)) < 0.001)
                    #expect(abs(voxels[2][2][2].blue - 0.25) < 0.001)
                }
            }
            try await group.waitForAll()
        }
    }

    @Test("Custom code prepares both render and compute pipelines")
    func customShaders() async throws {
        let image = try await Graphic.metal(code: "return float4(0.25, 0.5, 0.75, 1.0);", resolution: CGSize(width: 8, height: 8), options: .bit32)
        let processedImage = try await image.metal(code: "return float4(color.b, color.g, color.r, color.a);")
        let pixels = try await processedImage.pixelColors
        #expect(abs(pixels[4][4].red - 0.75) < 0.001)
        #expect(abs(pixels[4][4].blue - 0.25) < 0.001)

        let volume = try await Graphic3D.metal(code: "return float4(0.25, 0.5, 0.75, 1.0);", resolution: Size3D(width: 4, height: 4, depth: 4), options: .bit32)
        let voxels = try await volume.voxelColors
        #expect(abs(voxels[2][2][2].red - 0.25) < 0.001)
        #expect(abs(voxels[2][2][2].blue - 0.75) < 0.001)
    }

    @Test("Source replacement preserves the source texture")
    func sourceReplacement() async throws {
        let image = try await Graphic.color(.rawRed, resolution: CGSize(width: 8, height: 8))
        let result = try await image.inverted(options: .replace)
        #expect(result.texture === image.texture)
        let pixels = try await result.pixelColors
        #expect(pixels[4][4].red < 0.01)
        #expect(pixels[4][4].green > 0.99)
    }

    @RenderActor
    private func resources(
        shader: Renderer.Shader = .passthrough,
        bits: TMBits = ._8,
        is3D: Bool = false,
        recycleResolution: CGSize? = nil,
        options: Renderer.Options = Renderer.Options()
    ) throws -> Renderer.RenderResources {
        try Renderer.prepareRenderResources(
            shader: shader,
            bits: bits,
            sampleCount: 1,
            is3D: is3D,
            recycleResolution: recycleResolution,
            hasGraphics: true,
            options: options
        )
    }

    private func renderPipeline(_ resources: Renderer.RenderResources) throws -> MTLRenderPipelineState {
        guard case .render(let pipeline) = resources.pipeline else {
            throw ResourceTestError.expectedRenderPipeline
        }
        return pipeline
    }

    private func computePipeline(_ resources: Renderer.RenderResources) throws -> MTLComputePipelineState {
        guard case .compute(let pipeline) = resources.pipeline else {
            throw ResourceTestError.expectedComputePipeline
        }
        return pipeline
    }

    private func recyclableGraphic() throws -> Graphic {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 8, height: 8, mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        let texture = try #require(Renderer.metalDevice.makeTexture(descriptor: descriptor))
        return Graphic(name: "Resource Test", texture: texture, bits: ._8, colorSpace: .sRGB)
    }

    private enum ResourceTestError: Error {
        case expectedRenderPipeline
        case expectedComputePipeline
    }
}
