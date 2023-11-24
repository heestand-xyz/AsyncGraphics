//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import TextureMap

extension Renderer {
        
    static func pipeline(fragmentFunction: MTLFunction, 
                         vertexFunction: MTLFunction,
                         additive: Bool,
                         depth: Bool = false,
                         bits: TMBits,
                         sampleCount: Int = 1) throws -> MTLRenderPipelineState {
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.label = "AsyncGraphics Render Pipeline"
        pipeline.fragmentFunction = fragmentFunction
        pipeline.vertexFunction = vertexFunction
        if depth {
            pipeline.vertexDescriptor = vertexDescriptor()
        }
        pipeline.rasterSampleCount = sampleCount
        pipeline.colorAttachments[0].pixelFormat = bits.metalPixelFormat()
        pipeline.colorAttachments[0].isBlendingEnabled = true
        if additive {
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
            pipeline.depthAttachmentPixelFormat = .depth32Float
            pipeline.stencilAttachmentPixelFormat = .depth32Float_stencil8
        }
        return try metalDevice.makeRenderPipelineState(descriptor: pipeline)
    }
    
    static func pipeline3d(function: MTLFunction) throws -> MTLComputePipelineState {
        let pipelineStateDescriptor = MTLComputePipelineDescriptor()
        pipelineStateDescriptor.computeFunction = function
        return try metalDevice.makeComputePipelineState(descriptor: pipelineStateDescriptor, options: [], reflection: nil)
    }
}

extension Renderer {
     
    enum VertexAttribute: Int {
        case position
        case texcoord
    }
    
    enum BufferIndex: Int {
        case meshPositions
        case meshGenerics
        case uniforms
    }
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        
        let descriptor = MTLVertexDescriptor()

        descriptor.attributes[VertexAttribute.position.rawValue].format = MTLVertexFormat.float3
        descriptor.attributes[VertexAttribute.position.rawValue].offset = 0
        descriptor.attributes[VertexAttribute.position.rawValue].bufferIndex = BufferIndex.meshPositions.rawValue

        descriptor.attributes[VertexAttribute.texcoord.rawValue].format = MTLVertexFormat.float2
        descriptor.attributes[VertexAttribute.texcoord.rawValue].offset = 0
        descriptor.attributes[VertexAttribute.texcoord.rawValue].bufferIndex = BufferIndex.meshGenerics.rawValue

        descriptor.layouts[BufferIndex.meshPositions.rawValue].stride = 12
        descriptor.layouts[BufferIndex.meshPositions.rawValue].stepRate = 1
        descriptor.layouts[BufferIndex.meshPositions.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        descriptor.layouts[BufferIndex.meshGenerics.rawValue].stride = 8
        descriptor.layouts[BufferIndex.meshGenerics.rawValue].stepRate = 1
        descriptor.layouts[BufferIndex.meshGenerics.rawValue].stepFunction = MTLVertexStepFunction.perVertex

        return descriptor
    }
}
