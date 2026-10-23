import CoreGraphics
@preconcurrency import Metal
import TextureMap

extension Renderer {

    enum PreparedPipeline: Sendable {
        case render(MTLRenderPipelineState)
        case compute(MTLComputePipelineState)
    }

    struct RenderResources: Sendable {
        let optimization: Optimization
        let pipeline: PreparedPipeline
        let sampler: MTLSamplerState?
        let recycledTexture: MTLTexture?
    }

    private struct SamplerKey: Hashable, Sendable {
        let addressMode: MTLSamplerAddressMode
        let filter: MTLSamplerMinMagFilter
    }

    @RenderActor
    private static var samplerCache: [SamplerKey: MTLSamplerState] = [:]

    /// Resolve shared resources in one actor turn. Texture allocation, command
    /// encoding, and GPU completion remain outside this actor.
    @RenderActor
    static func prepareRenderResources(
        shader: Shader,
        bits: TMBits,
        sampleCount: Int,
        is3D: Bool,
        recycleResolution: CGSize?,
        hasGraphics: Bool,
        options: Options
    ) throws -> RenderResources {
        let optimization = Self.optimization
        let pipeline: PreparedPipeline
        if is3D {
            pipeline = .compute(try pipeline3d(proxy: Pipeline3DProxy(shader: shader)))
        } else {
            pipeline = .render(try self.pipeline(proxy: PipelineProxy(
                shader: shader,
                additive: options.additive,
                depth: options.depth,
                stencil: options.stencil,
                bits: bits,
                sampleCount: sampleCount
            )))
        }

        let sampler: MTLSamplerState?
        if hasGraphics {
            let key = SamplerKey(addressMode: options.addressMode, filter: options.filter)
            if optimization.contains(.cacheSampler), let cached = samplerCache[key] {
                sampler = cached
            } else {
                let newSampler = try self.sampler(addressMode: options.addressMode, filter: options.filter)
                if optimization.contains(.cacheSampler) {
                    samplerCache[key] = newSampler
                }
                sampler = newSampler
            }
        } else {
            sampler = nil
        }

        // Claim the texture without suspending between inspection and removal.
        let recycledTexture: MTLTexture?
        if !options.targetSourceTexture,
           let recycleResolution,
           let recycleGraphic,
           recycleGraphic.resolution == recycleResolution,
           recycleGraphic.bits == bits {
            recycledTexture = recycleGraphic.texture
            self.recycleGraphic = nil
        } else {
            recycledTexture = nil
        }

        return RenderResources(
            optimization: optimization,
            pipeline: pipeline,
            sampler: sampler,
            recycledTexture: recycledTexture
        )
    }
}
