//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import TextureMap

extension Renderer {
    
    struct PipelineProxy: Hashable {
        let shader: Shader
        let additive: Bool
        let depth: Bool
        let stencil: Bool
        let bits: TMBits
        let sampleCount: Int
    }
        
    struct Pipeline3DProxy: Hashable {
        let shader: Shader
    }
        
    static func pipeline(
        proxy: PipelineProxy
    ) throws -> MTLRenderPipelineState {
        
        if optimizationMode {
            if let pipeline: MTLRenderPipelineState = storeQueue.sync(execute: {
                storedRenderPipelines[proxy]
            }) {
                return pipeline
            }
        }
        
        /// 2 ~ 10 %
        let fragmentFunction: MTLFunction = try {
            switch proxy.shader {
            case .code(let code, let name):
                return try self.shader(name: name, code: code)
            default:
                return try self.shader(name: proxy.shader.fragmentName)
            }
        }()
        
        let vertexFunction: MTLFunction = try self.shader(name: proxy.shader.vertexName)
        
        let pipeline: MTLRenderPipelineState = try pipeline(
            fragmentFunction: fragmentFunction,
            vertexFunction: vertexFunction,
            additive: proxy.additive,
            depth: proxy.depth,
            stencil: proxy.stencil,
            bits: proxy.bits,
            sampleCount: proxy.sampleCount
        )
        
        if optimizationMode {
            storeQueue.async(flags: .barrier) {
                storedRenderPipelines[proxy] = pipeline
            }
        }
        
        return pipeline
    }
    
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
    
    static func pipeline3d(
        proxy: Pipeline3DProxy
    ) throws -> MTLComputePipelineState {
        
        if optimizationMode {
            if let pipeline: MTLComputePipelineState = storeQueue.sync(execute: {
                storedComputePipelines[proxy]
            }) {
                return pipeline
            }
        }
        
        let computeFunction: MTLFunction = try {
            switch proxy.shader {
            case .code(let code, let name):
                return try self.shader(name: name, code: code)
            default:
                return try self.shader(name: proxy.shader.fragmentName)
            }
        }()
        
        let pipeline: MTLComputePipelineState = try pipeline3d(
            function: computeFunction
        )
        
        if optimizationMode {
            storeQueue.async(flags: .barrier) {
                storedComputePipelines[proxy] = pipeline
            }
        }
        
        return pipeline
    }
    
    static func pipeline3d(
        function: MTLFunction
    ) throws -> MTLComputePipelineState {
        let pipelineStateDescriptor = MTLComputePipelineDescriptor()
        pipelineStateDescriptor.computeFunction = function
        return try metalDevice.makeComputePipelineState(descriptor: pipelineStateDescriptor, options: [], reflection: nil)
    }
}
