//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import TextureMap

extension Renderer {
        
    static func pipeline(
        fragmentFunction: MTLFunction,
        vertexFunction: MTLFunction,
        additive: Bool,
        depth: Bool = false,
        stencil: Bool = false,
        bits: TMBits,
        sampleCount: Int = 1
    ) throws -> MTLRenderPipelineState {
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.label = "AsyncGraphics Render Pipeline"
        pipeline.fragmentFunction = fragmentFunction
        pipeline.vertexFunction = vertexFunction
        pipeline.rasterSampleCount = sampleCount
        pipeline.colorAttachments[0].pixelFormat = bits.metalPixelFormat()
        pipeline.colorAttachments[0].isBlendingEnabled = true
        if depth {
            pipeline.colorAttachments[0].alphaBlendOperation = .add
            pipeline.colorAttachments[0].rgbBlendOperation = .add
            pipeline.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipeline.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipeline.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipeline.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        } else if additive {
            pipeline.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipeline.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipeline.colorAttachments[0].destinationRGBBlendFactor = .one
            pipeline.colorAttachments[0].destinationAlphaBlendFactor = .one
            pipeline.colorAttachments[0].rgbBlendOperation = .add
            pipeline.colorAttachments[0].alphaBlendOperation = .add
        } else {
            pipeline.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        }
        if depth {
            pipeline.depthAttachmentPixelFormat = stencil ? .depth32Float_stencil8 : .depth32Float
            pipeline.stencilAttachmentPixelFormat = stencil ? .depth32Float_stencil8 : .invalid
        }
        return try metalDevice.makeRenderPipelineState(descriptor: pipeline)
    }
    
    static func pipeline3d(function: MTLFunction) throws -> MTLComputePipelineState {
        let pipelineStateDescriptor = MTLComputePipelineDescriptor()
        pipelineStateDescriptor.computeFunction = function
        return try metalDevice.makeComputePipelineState(descriptor: pipelineStateDescriptor, options: [], reflection: nil)
    }
}
