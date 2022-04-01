//
//  AGRenderer.swift
//  LiveGraphics
//
//  Created by Anton Heestand on 2021-09-18.
//

import Foundation
//import AppKit
import MetalKit
import TextureMap

struct AGRenderer {
    
    static let metalDevice: MTLDevice = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Device Not Supported")
        }
        return device
    }()
    
    enum AGRendererError: Error {
        case textureCGImage
        case emptyTexture
        case vertexQuadBuffer
        case shaderFunction
        case commandBuffer
        case commandEncoder
        case commandQueue
        case textureCache
        case sampler
        case image
    }
    
    static func render(as shaderName: String, texture: MTLTexture, bits: TMBits) async throws -> MTLTexture {
        
        try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                 
                    let destinationTexture: MTLTexture = try TextureMap.emptyTexture(size: texture.size, bits: bits)
                    
                    guard let commandQueue = metalDevice.makeCommandQueue() else {
                        throw AGRendererError.commandQueue
                    }
                    guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
                        throw AGRendererError.commandBuffer
                    }
                    
                    let commandEncoder: MTLRenderCommandEncoder = try commandEncoder(texture: destinationTexture, commandBuffer: commandBuffer)
                    
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
                    
                    DispatchQueue.main.async {
                        
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}

// MARK: - Pipeline

extension AGRenderer {
    
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

extension AGRenderer {
    
    static func commandEncoder(texture: MTLTexture, commandBuffer: MTLCommandBuffer) throws -> MTLRenderCommandEncoder {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw AGRendererError.commandEncoder
        }
        return commandEncoder
    }
}

// MARK: - Sampler

extension AGRenderer {
    
    static func sampler() throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = .linear
        samplerInfo.magFilter = .linear
        samplerInfo.sAddressMode = .clampToZero
        samplerInfo.tAddressMode = .clampToZero
        samplerInfo.compareFunction = .never
        samplerInfo.mipFilter = .linear
        guard let sampler = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw AGRendererError.sampler
        }
        return sampler
    }
}

// MARK: - Vertex Quad

extension AGRenderer {
    
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
            throw AGRendererError.vertexQuadBuffer
        }
        return buffer
    }
}

// MARK: - Shader

extension AGRenderer {
    
    static func shader(name: String) throws -> MTLFunction {
        let metalLibrary: MTLLibrary = try metalDevice.makeDefaultLibrary(bundle: Bundle.main)
        guard let shader = metalLibrary.makeFunction(name: name) else {
            throw AGRendererError.shaderFunction
        }
        return shader
    }
}
