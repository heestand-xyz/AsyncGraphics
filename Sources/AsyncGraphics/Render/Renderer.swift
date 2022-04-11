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
        
        case badMetadata
        case failedToMakeVertexQuadBuffer
        case shaderFunctionNotFound(name: String)
        case failedToMakeCommandBuffer
        case failedToMakeCommandEncoder
        case failedToMakeCommandQueue
        case failedToMakeSampler
        case failedToMakeUniformBuffer
        case failedToMakeComputeCommandEncoder
        
        var errorDescription: String? {
            switch self {
            case .badMetadata:
                return "Async Graphics - Renderer - Bad Metadata"
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
            case .failedToMakeUniformBuffer:
                return "Async Graphics - Renderer - Failed to Make Uniform Buffer"
            case .failedToMakeComputeCommandEncoder:
                return "Async Graphics - Renderer - Failed to Make Compute Command Encoder"
            }
        }
    }
    
    struct EmptyUniforms {}
    
    static func render<G: Graphicable>(name: String,
                                       shaderName: String,
                                       graphics: [Graphicable] = [],
                                       resolution: Resolution? = nil,
                                       colorSpace: TMColorSpace? = nil,
                                       bits: TMBits? = nil) async throws -> G {
        
        try await render(name: name,
                         shaderName: shaderName,
                         graphics: graphics,
                         uniforms: EmptyUniforms(),
                         resolution: resolution,
                         colorSpace: colorSpace,
                         bits: bits)
    }
    
    static func render<U, G: Graphicable>(name: String,
                                          shaderName: String,
                                          graphics: [Graphicable] = [],
                                          uniforms: U,
                                          resolution: Resolution? = nil,
                                          colorSpace: TMColorSpace? = nil,
                                          bits: TMBits? = nil) async throws -> G {
        
        guard let resolution: Resolution = resolution ?? {
            if let graphic = graphics.first as? Graphic {
                return graphic.resolution
            } else if let graphic3d = graphics.first as? Graphic3D {
                return graphic3d.resolution
            }
            return nil
        }(),
              let colorSpace: TMColorSpace = colorSpace ?? graphics.first?.colorSpace,
              let bits: TMBits = bits ?? graphics.first?.bits else {
            throw RendererError.badMetadata
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    let targetTexture: MTLTexture = try {
                        if let resolution: CGSize = resolution as? CGSize {
                            return try TextureMap.emptyTexture(resolution: resolution, bits: bits)
                        } else if let resolution: SIMD3<Int> = resolution as? SIMD3<Int> {
                            return try TextureMap.emptyTexture3d(resolution: resolution, bits: bits, usage: .write)
                        }
                        fatalError("Unknown Graphicable")
                    }()
                    
                    guard let commandQueue = metalDevice.makeCommandQueue() else {
                        throw RendererError.failedToMakeCommandQueue
                    }
                    
                    guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
                        throw RendererError.failedToMakeCommandBuffer
                    }
                    
                    let commandEncoder: MTLCommandEncoder
                    if resolution is SIMD3<Int> {
                        guard let computeCommandEncoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
                            throw RendererError.failedToMakeComputeCommandEncoder
                        }
                        commandEncoder = computeCommandEncoder
                    } else {
                        let renderCommandEncoder: MTLRenderCommandEncoder = try self.commandEncoder(texture: targetTexture, commandBuffer: commandBuffer)
                        commandEncoder = renderCommandEncoder
                    }
                    
                    do {
                        
                        // MARK: Pipeline
                        
                        if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                            
                            let pipeline: MTLRenderPipelineState = try pipeline(as: shaderName, bits: bits)
                            renderCommandEncoder.setRenderPipelineState(pipeline)
                            
                        } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                            
                            let pipeline3d: MTLComputePipelineState = try pipeline3d(as: shaderName)
                            computeCommandEncoder.setComputePipelineState(pipeline3d)
                        }
                        
                        // MARK: Textures
                        
                        if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                            computeCommandEncoder.setTexture(targetTexture, index: 0)
                        }
                        
                        if !graphics.isEmpty {
                            
                            for (index, graphic) in graphics.enumerated() {
                                
                                if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                    
                                    renderCommandEncoder.setFragmentTexture(graphic.texture, index: index)
                                    
                                } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                                    
                                    computeCommandEncoder.setTexture(graphic.texture, index: index)
                                }
                            }
                            
                            // MARK: Sampler
                            
                            let sampler: MTLSamplerState = try sampler()
                            
                            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                
                                renderCommandEncoder.setFragmentSamplerState(sampler, index: 0)
                                
                            } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                                
                                computeCommandEncoder.setSamplerState(sampler, index: 0)
                            }
                        }
                        
                        // MARK: Uniforms

                        if uniforms is EmptyUniforms == false {
                            
                            var uniforms: U = uniforms
                            
                            let size = MemoryLayout<U>.size
                            
                            guard let uniformsBuffer = metalDevice.makeBuffer(bytes: &uniforms, length: size) else {
                                throw RendererError.failedToMakeUniformBuffer
                            }
                            
                            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                
                                renderCommandEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
                                
                            } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                                
                                computeCommandEncoder.setBuffer(uniformsBuffer, offset: 0, index: 0)
                            }
                        }
                        
                        // MARK: Vertex
                        
                        if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                            
                            let vertexBuffer: MTLBuffer = try vertexQuadBuffer()
                            
                            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                        }
                        
                        // MARK: Draw
                        
                        if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                         
                            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
                            
                        } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                            
                            let threadsPerThreadGroup = MTLSize(width: 8, height: 8, depth: 8)
                            
                            let threadsPerGrid: MTLSize
                            if let resolution: SIMD3<Int> = resolution as? SIMD3<Int> {
                                threadsPerGrid = MTLSize(width: resolution.x, height: resolution.y, depth: resolution.z)
                            } else {
                                fatalError("3D resolution not found")
                            }
                            
//                            #if !os(tvOS)
                            computeCommandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
//                            #else
//                            fatalError("3D graphics rendering on tvOS is not supported")
//                            #endif
                        }
                        
                        // MARK: Render
                        
                        commandEncoder.endEncoding()
                        
                        commandBuffer.addCompletedHandler { _ in
                            
                            DispatchQueue.main.async {
                                
                                let graphic = G(name: name,
                                                texture: targetTexture,
                                                bits: bits,
                                                colorSpace: colorSpace)
                                
                                continuation.resume(returning: graphic)
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
    
    static func pipeline(as shaderName: String, bits: TMBits) throws -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = try shader(name: "vertexQuad")
        pipelineStateDescriptor.fragmentFunction = try shader(name: shaderName)
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = bits.metalPixelFormat()
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    static func pipeline3d(as shaderName: String) throws -> MTLComputePipelineState {
        let function = try shader(name: shaderName)
        return try metalDevice.makeComputePipelineState(function: function)
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
        samplerInfo.mipFilter = .linear
        samplerInfo.minFilter = .linear
        samplerInfo.magFilter = .linear
        samplerInfo.sAddressMode = .clampToZero
        samplerInfo.tAddressMode = .clampToZero
        samplerInfo.rAddressMode = .clampToZero
        samplerInfo.compareFunction = .never
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
        let a = Vertex(x: -1.0, y: -1.0, s: 0.0, t: 1.0)
        let b = Vertex(x: 1.0, y: -1.0, s: 1.0, t: 1.0)
        let c = Vertex(x: -1.0, y: 1.0, s: 0.0, t: 0.0)
        let d = Vertex(x: 1.0, y: 1.0, s: 1.0, t: 0.0)
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
