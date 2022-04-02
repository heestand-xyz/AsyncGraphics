//
//  Renderer.swift
//  LiveGraphics
//
//  Created by Anton Heestand on 2021-09-18.
//

import Foundation
import MetalKit
import TextureMap

struct Renderer {
    
    static let metalDevice: MTLDevice = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Device Not Supported")
        }
        return device
    }()
    
    enum RendererError: LocalizedError {
        
        case failedToMakeVertexQuadBuffer
        case shaderFunctionNotFound(name: String)
        case failedToMakeCommandBuffer
        case failedToMakeCommandEncoder
        case failedToMakeCommandQueue
        case failedToMakeSampler
        
        var errorDescription: String? {
            switch self {
            case .failedToMakeVertexQuadBuffer:
                return "Async Graphics - Renderer - Failed to Make Vertex Quad Buffer"
            case .shaderFunctionNotFound(let name):
                return "Async Graphics - Renderer - Shader Function Not Found (\"\(name)\")"
            case .failedToMakeCommandBuffer:
                return "Async Graphics - Renderer - Failed to Make Command Buffer"
            case .failedToMakeCommandEncoder:
                return "Async Graphics - Renderer - Failed to Make Command Encoder"
            case .failedToMakeCommandQueue:
                return "Async Graphics - Renderer - Failed to Make Command Queue"
            case .failedToMakeSampler:
                return "Async Graphics - Renderer - Failed to Make Sampler"
            }
        }
    }
    
    static func render(as shaderName: String, texture: MTLTexture, bits: TMBits) async throws -> MTLTexture {
        
        try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    let destinationTexture: MTLTexture = try TextureMap.emptyTexture(size: texture.size, bits: bits)
                    
                    guard let commandQueue = metalDevice.makeCommandQueue() else {
                        throw RendererError.failedToMakeCommandQueue
                    }
                    
                    guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
                        throw RendererError.failedToMakeCommandBuffer
                    }
                    
                    let commandEncoder: MTLRenderCommandEncoder = try commandEncoder(texture: destinationTexture, commandBuffer: commandBuffer)
                    
                    do {
                        
                        let pipeline: MTLRenderPipelineState = try pipeline(as: shaderName)
                        
                        let sampler: MTLSamplerState = try sampler()
                        
                        let vertexBuffer: MTLBuffer = try vertexQuadBuffer()
                        
                        commandEncoder.setRenderPipelineState(pipeline)
                        
                        commandEncoder.setFragmentTexture(texture, index: 0)
                        
                        commandEncoder.setFragmentSamplerState(sampler, index: 0)
                        
                        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
                        
                        commandEncoder.endEncoding()
                        
                        commandBuffer.addCompletedHandler { _ in
                            
                            DispatchQueue.main.async {
                                
                                continuation.resume(returning: destinationTexture)
                            }
                        }
                        
                        commandBuffer.commit()
                        
                    } catch {
                        
                        commandEncoder.endEncoding()
                        
                        DispatchQueue.main.async {
                            
                            continuation.resume(throwing: error)
                        }
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}

// MARK: - Pipeline

extension Renderer {
    
    static func pipeline(as shaderName: String) throws -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = try shader(name: "vertexQuad")
        pipelineStateDescriptor.fragmentFunction = try shader(name: shaderName)
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

// MARK: - Command Encoder

extension Renderer {
    
    static func commandEncoder(texture: MTLTexture, commandBuffer: MTLCommandBuffer) throws -> MTLRenderCommandEncoder {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw RendererError.failedToMakeCommandEncoder
        }
        return commandEncoder
    }
}

// MARK: - Sampler

extension Renderer {
    
    static func sampler() throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = .linear
        samplerInfo.magFilter = .linear
        samplerInfo.sAddressMode = .clampToZero
        samplerInfo.tAddressMode = .clampToZero
        samplerInfo.compareFunction = .never
        samplerInfo.mipFilter = .linear
        guard let sampler = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw RendererError.failedToMakeSampler
        }
        return sampler
    }
}

// MARK: - Vertex Quad

extension Renderer {
    
    struct Vertex {
        let x, y: CGFloat
        let s, t: CGFloat
        var buffer: [Float] {
            [x, y, s, t].map(Float.init)
        }
    }
    
    static func vertexQuadBuffer() throws -> MTLBuffer {
        let a = Vertex(x: -1.0, y: -1.0, s: 0.0, t: 0.0)
        let b = Vertex(x: 1.0, y: -1.0, s: 1.0, t: 0.0)
        let c = Vertex(x: -1.0, y: 1.0, s: 0.0, t: 1.0)
        let d = Vertex(x: 1.0, y: 1.0, s: 1.0, t: 1.0)
        let vertices: [Vertex] = [a, b, c, b, c, d]
        let vertexBuffer: [Float] = vertices.flatMap(\.buffer)
        let dataSize = vertexBuffer.count * MemoryLayout.size(ofValue: vertexBuffer[0])
        guard let buffer = metalDevice.makeBuffer(bytes: vertexBuffer, length: dataSize, options: []) else {
            throw RendererError.failedToMakeVertexQuadBuffer
        }
        return buffer
    }
}

// MARK: - Shader

extension Renderer {
    
    static func shader(name: String) throws -> MTLFunction {
        let metalLibrary: MTLLibrary = try metalDevice.makeDefaultLibrary(bundle: .module)
        guard let shader = metalLibrary.makeFunction(name: name) else {
            throw RendererError.shaderFunctionNotFound(name: name)
        }
        return shader
    }
}
