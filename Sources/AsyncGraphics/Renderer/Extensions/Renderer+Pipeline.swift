//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import TextureMap

extension Renderer {
        
    static func pipeline(fragmentFunction: MTLFunction, vertexFunction: MTLFunction, additive: Bool, bits: TMBits, sampleCount: Int = 1) throws -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.rasterSampleCount = sampleCount
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = bits.metalPixelFormat()
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        if additive {
            pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .one
            pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
            pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add
        } else {
            pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        }
        return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    static func pipeline3d(function: MTLFunction) throws -> MTLComputePipelineState {
        let pipelineStateDescriptor = MTLComputePipelineDescriptor()
        pipelineStateDescriptor.computeFunction = function
        return try metalDevice.makeComputePipelineState(descriptor: pipelineStateDescriptor, options: [], reflection: nil)
    }
}
