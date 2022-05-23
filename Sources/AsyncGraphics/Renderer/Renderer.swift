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
    
    /// Hardcoded. Defined as ARRMAX in shaders.
    private static let uniformArrayMaxLimit: Int = 128
    
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
        case failedToMakeArrayUniformBuffer
        case failedToMakeVertexUniformBuffer
        case failedToMakeComputeCommandEncoder
        case graphic3dIsCurrentlyOnlySupportedOnMacOS
        
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
            case .failedToMakeArrayUniformBuffer:
                return "Async Graphics - Renderer - Failed to Make Array Uniform Buffer"
            case .failedToMakeVertexUniformBuffer:
                return "Async Graphics - Renderer - Failed to Make Vertex Uniform Buffer"
            case .failedToMakeComputeCommandEncoder:
                return "Async Graphics - Renderer - Failed to Make Compute Command Encoder"
            case .graphic3dIsCurrentlyOnlySupportedOnMacOS:
                return "Async Graphics - Renderer - Graphic3D is Currently Only Supported on macOS"
            }
        }
    }
    
    /// Simple
    static func render<G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        metadata: Metadata? = nil,
        options: Options = Options()
    ) async throws -> G {
        
        try await render(
            name: name,
            shader: shader,
            graphics: graphics,
            uniforms: EmptyUniforms(),
            arrayUniforms: [],
            emptyArrayUniform: EmptyUniforms(),
            vertexUniforms: EmptyUniforms(),
            metadata: metadata,
            options: options
        )
    }
    
    /// Basic
    static func render<U, G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U,
        metadata: Metadata? = nil,
        options: Options = Options()
    ) async throws -> G {
        
        try await render(
            name: name,
            shader: shader,
            graphics: graphics,
            uniforms: uniforms,
            arrayUniforms: [],
            emptyArrayUniform: EmptyUniforms(),
            vertexUniforms: EmptyUniforms(),
            metadata: metadata,
            options: options
        )
    }
    
    /// Array
    static func render<U, AU, G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U,
        arrayUniforms: [AU],
        emptyArrayUniform: AU,
        metadata: Metadata? = nil,
        options: Options = Options()
    ) async throws -> G {
        
        try await render(
            name: name,
            shader: shader,
            graphics: graphics,
            uniforms: uniforms,
            arrayUniforms: arrayUniforms,
            emptyArrayUniform: emptyArrayUniform,
            vertexUniforms: EmptyUniforms(),
            metadata: metadata,
            options: options
        )
    }
    
    /// Vertex
    static func render<U, VU, G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U,
        vertexUniforms: VU,
        vertexCount: Int? = nil,
        metadata: Metadata? = nil,
        options: Options = Options()
    ) async throws -> G {
        
        try await render(
            name: name,
            shader: shader,
            graphics: graphics,
            uniforms: uniforms,
            arrayUniforms: [],
            emptyArrayUniform: EmptyUniforms(),
            vertexUniforms: vertexUniforms,
            vertexCount: vertexCount,
            metadata: metadata,
            options: options
        )
    }
    
    /// Main
    private static func render<U, AU, VU, G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U,
        arrayUniforms: [AU],
        emptyArrayUniform: AU,
        vertexUniforms: VU,
        vertexCount: Int? = nil,
        metadata: Metadata? = nil,
        options: Options = Options()
    ) async throws -> G {
        
        guard let resolution: MultiDimensionalResolution = metadata?.resolution ?? {
            if let graphic = graphics.first as? Graphic {
                return graphic.resolution
            } else if let graphic3d = graphics.first as? Graphic3D {
                return graphic3d.resolution
            }
            return nil
        }(),
        let colorSpace: TMColorSpace = metadata?.colorSpace ?? graphics.first?.colorSpace,
            let bits: TMBits = metadata?.bits ?? graphics.first?.bits else {
                throw RendererError.badMetadata
            }
        
        let arrayTexture: MTLTexture? = options.isArray ? try await graphics.map(\.texture).texture(type: .typeArray) : nil
            
        return try await withCheckedThrowingContinuation { continuation in
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    let targetTexture: MTLTexture = try {
                        if let resolution: CGSize = resolution as? CGSize {
                            return try .empty(resolution: resolution, bits: bits)
                        } else if let resolution: SIMD3<Int> = resolution as? SIMD3<Int> {
                            return try .empty3d(resolution: resolution, bits: bits, usage: .write)
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
                        let renderCommandEncoder: MTLRenderCommandEncoder = try self.commandEncoder(texture: targetTexture, clearColor: options.clearColor, commandBuffer: commandBuffer)
                        commandEncoder = renderCommandEncoder
                    }
                    
                    do {
                        
                        // MARK: Pipeline
                         
                        let function: MTLFunction = try {
                            switch shader {
                            case .name(let name), .custom(let name, _):
                                return try self.shader(name: name)
                            case .code(let code, let name):
                                return try self.shader(name: name, code: code)
                            }
                        }()
                        
                        if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                        
                            let vertexShaderName: String = {
                                switch shader {
                                case .custom(_, let vertex):
                                    return vertex
                                default:
                                    return "vertexQuad"
                                }
                            }()
                            
                            let vertexFunction = try self.shader(name: vertexShaderName)
                            
                            let pipeline: MTLRenderPipelineState = try pipeline(fragmentFunction: function, vertexFunction: vertexFunction, additive: options.additive, bits: bits)
                            renderCommandEncoder.setRenderPipelineState(pipeline)
                            
                        } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                            
                            let pipeline3d: MTLComputePipelineState = try pipeline3d(function: function)
                            computeCommandEncoder.setComputePipelineState(pipeline3d)
                        }
                        
                        // MARK: Textures
                        
                        if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                            computeCommandEncoder.setTexture(targetTexture, index: 0)
                        }
                        
                        if !graphics.isEmpty {
                            
                            if let arrayTexture: MTLTexture = arrayTexture {
                                
                                if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                    
                                    renderCommandEncoder.setFragmentTexture(arrayTexture, index: 0)
                                }
                                
                            } else {
                            
                                for (index, graphic) in graphics.enumerated() {
                                    
                                    if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                        
                                        if case .custom = shader {
                                            renderCommandEncoder.setVertexTexture(graphic.texture, index: index)
                                        } else {
                                            renderCommandEncoder.setFragmentTexture(graphic.texture, index: index)
                                        }
                                        
                                    } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                                        
                                        computeCommandEncoder.setTexture(graphic.texture, index: index + 1)
                                    }
                                }
                            }
                            
                            // MARK: Sampler
                            
                            let sampler: MTLSamplerState = try sampler(addressMode: options.addressMode)
                            
                            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                
                                if case .custom = shader {
                                    renderCommandEncoder.setVertexSamplerState(sampler, index: 0)
                                } else {
                                    renderCommandEncoder.setFragmentSamplerState(sampler, index: 0)
                                }
                                
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
                        
                        // MARK: Array Uniforms
                        
                        if !arrayUniforms.isEmpty {
                        
                            var fixedArrayUniforms: [AU] = arrayUniforms
                            var fixedActiveArrayUniforms: [Bool] = Array(repeating: true, count: arrayUniforms.count)
                            
                            if arrayUniforms.count <= Self.uniformArrayMaxLimit {
                                for _ in arrayUniforms.count..<Self.uniformArrayMaxLimit {
                                    var emptyArray: [Float] = []
                                    fixedArrayUniforms.append(emptyArrayUniform)
                                    fixedActiveArrayUniforms.append(false)
                                }
                            } else {
                                let originalCount = arrayUniforms.count
                                let overflow = originalCount - Self.uniformArrayMaxLimit
                                for _ in 0..<overflow {
                                    fixedArrayUniforms.removeLast()
                                    fixedActiveArrayUniforms.removeLast()
                                }
                                print("AsyncGraphics - Renderer - Max limit of uniform arrays exceeded. Trailing values will be truncated. \(originalCount) / \(Self.uniformArrayMaxLimit)")
                            }
                                                        
                            let size: Int = MemoryLayout<AU>.size * Self.uniformArrayMaxLimit
                            let activeSize: Int = MemoryLayout<Bool>.size * Self.uniformArrayMaxLimit
                            
                            guard let arrayUniformsBuffer = metalDevice.makeBuffer(bytes: &fixedArrayUniforms, length: size),
                                  let activeArrayUniformsBuffer = metalDevice.makeBuffer(bytes: &fixedActiveArrayUniforms, length: activeSize) else {
                                throw RendererError.failedToMakeArrayUniformBuffer
                            }
                            
                            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                
                                renderCommandEncoder.setFragmentBuffer(arrayUniformsBuffer, offset: 0, index: 1)
                                renderCommandEncoder.setFragmentBuffer(activeArrayUniformsBuffer, offset: 0, index: 2)
                                
                            } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                                
                                computeCommandEncoder.setBuffer(arrayUniformsBuffer, offset: 0, index: 1)
                                computeCommandEncoder.setBuffer(activeArrayUniformsBuffer, offset: 0, index: 2)
                            }
                        }
                        
                        // MARK: Vertex Uniforms
                        
                        if vertexUniforms is EmptyUniforms == false {
                            
                            var uniforms: VU = vertexUniforms
                            
                            let size = MemoryLayout<VU>.size
                            
                            guard let uniformsBuffer = metalDevice.makeBuffer(bytes: &uniforms, length: size) else {
                                throw RendererError.failedToMakeVertexUniformBuffer
                            }
                            
                            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                                
                                renderCommandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 0)
                            }
                        }
                        
                        // MARK: Vertex
                        
                        if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                            
                            if vertexCount == nil {
                                let vertexBuffer: MTLBuffer = try vertexQuadBuffer()
                                renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                            }
                        }
                        
                        // MARK: Draw
                        
                        if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                         
                            renderCommandEncoder.drawPrimitives(type: vertexCount != nil ? .point : .triangle,
                                                                vertexStart: 0,
                                                                vertexCount: vertexCount ?? 6,
                                                                instanceCount: 1)
                            
                        } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                            
                            #if os(macOS)
                            
                            let threadsPerThreadGroup = MTLSize(width: 8, height: 8, depth: 8)
                            
                            let threadsPerGrid: MTLSize
                            if let resolution: SIMD3<Int> = resolution as? SIMD3<Int> {
                                threadsPerGrid = MTLSize(width: resolution.x, height: resolution.y, depth: resolution.z)
                            } else {
                                fatalError("3D resolution not found")
                            }
                            
                            computeCommandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)

                            #else
                            // Dispatch Threads with Non-Uniform Threadgroup Size is not supported on this device
                            throw RendererError.graphic3dIsCurrentlyOnlySupportedOnMacOS
                            #endif
                            
                        }
                        
                        // MARK: Render
                        
                        commandEncoder.endEncoding()
                        
                        commandBuffer.addCompletedHandler { _ in
                            
                            DispatchQueue.main.async {
                                
                                let graphic = G(id: UUID(),
                                                name: name,
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
