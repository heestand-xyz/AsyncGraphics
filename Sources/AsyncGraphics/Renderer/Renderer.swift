//
//  Renderer.swift
//  LiveGraphics
//
//  Created by Anton Heestand on 2021-09-18.
//

import Foundation
import SwiftUI
@preconcurrency import Metal
import MetalKit
import TextureMap
import Spatial

@globalActor
public actor RenderActor {
    public static let shared = RenderActor()
    @discardableResult
    public static func run<T: Sendable>(_ operation: @escaping @RenderActor () async throws -> T) async rethrows -> T {
        try await operation()
    }
}

public struct Renderer {
    
    /// *Experimental* performance optimisations.
    @available(*, unavailable, renamed: "optimization")
    @RenderActor
    public static var optimizationMode: Bool = true
    
    public struct Optimization: OptionSet, Hashable, Sendable {
        
        public let rawValue: Int
        
        /// Remove this option if you run a lot of parallel renders.
        public static let cacheCommandQueue = Optimization(rawValue: 1 << 0)
        public static let cacheQuadVertexBuffer = Optimization(rawValue: 1 << 1)
        public static let cachePipelineState = Optimization(rawValue: 1 << 2)
        
        public static var all: Optimization {
            [
                .cacheCommandQueue,
                .cacheQuadVertexBuffer,
                .cachePipelineState,
            ]
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// By default all optimizations are enabled.
    @RenderActor
    public static var optimization: Optimization = .all
    
    /// Hardcoded. Defined as ARRMAX in shaders.
    private static let uniformArrayMaxLimit: Int = 128
    
    public static let metalDevice: MTLDevice = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Device Not Supported")
        }
        return device
    }()
    
    @RenderActor
    public static var customMetalLibrary: MTLLibrary?
    
    @RenderActor
    public static var defaultMetalLibrary: MTLLibrary? = {
        do {
            return try metalDevice.makeDefaultLibrary(bundle: .module)
        } catch {
            print("AsyncGraphics - Default metal library not found. Please provide a metal library with: `Renderer.customMetalLibrary = ...`. Error:", error)
            return nil
        }
    }()
    
    /// This is the `customMetalLibrary` if available, otherwise it is the `defaultMetalLibrary`.
    @RenderActor
    public static var metalLibrary: MTLLibrary? {
        customMetalLibrary ?? defaultMetalLibrary
    }
    
    @RenderActor
    private static var storedCommandQueue: MTLCommandQueue?
    @RenderActor
    static var storedRenderPipelines: [PipelineProxy: MTLRenderPipelineState] = [:]
    @RenderActor
    static var storedComputePipelines: [Pipeline3DProxy: MTLComputePipelineState] = [:]
    static let storedVertexQuadBuffer: MTLBuffer? = try? makeVertexQuadBuffer()
    
    @RenderActor
    public static func commandQueue() -> MTLCommandQueue? {
        if optimization.contains(.cacheCommandQueue) {
            if let storedCommandQueue: MTLCommandQueue {
                return storedCommandQueue
            } else {
                storedCommandQueue = metalDevice.makeCommandQueue()
                return storedCommandQueue
            }
        } else {
            return metalDevice.makeCommandQueue()
        }
    }
    
    /// Basic
    static func render<U, G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U = EmptyUniforms(),
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
        uniforms: U = EmptyUniforms(),
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
    
    /// Camera
    static func render<U>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U = EmptyUniforms(),
        vertices: Vertices,
        camera: Camera,
        rotationX: Angle = .zero,
        rotationY: Angle = .zero,
        rotationZ: Angle = .zero,
        metadata: Metadata? = nil,
        options: Options = Options()
    ) async throws -> Graphic {
        
        guard options.depth else {
            fatalError("Depth Option Must be True for Camera")
        }
        
        guard let resolution: CGSize = metadata?.resolution as? CGSize else {
            fatalError("2D Resolution Needed for Camera Rendering")
        }
        
        let projectionMatrix: matrix_float4x4 = perspective(
            fovyRadians: radians(degrees: Float(camera.fieldOfView.degrees)),
            aspectRatio: Float(resolution.aspectRatio),
            nearZ: Float(camera.near),
            farZ: Float(camera.far))
        
        let position: matrix_float4x4 = translation(Float(camera.position.x),
                                                    Float(camera.position.y),
                                                    Float(camera.position.z))
        let rotationX: matrix_float4x4 = rotation(radians: Float(rotationX.radians),
                                                  axis: SIMD3<Float>(1, 0, 0))
        let rotationY: matrix_float4x4 = rotation(radians: Float(rotationY.radians),
                                                  axis: SIMD3<Float>(0, 1, 0))
        let rotationZ: matrix_float4x4 = rotation(radians: Float(rotationZ.radians),
                                                  axis: SIMD3<Float>(0, 0, 1))
        let rotation: matrix_float4x4 = simd_mul(simd_mul(rotationX, rotationY), rotationZ)
        let modelViewMatrix: matrix_float4x4 = simd_mul(position, rotation)
        
        let cameraUniforms = CameraUniforms(
            projectionMatrix: projectionMatrix,
            modelViewMatrix: modelViewMatrix)

        return try await render(
            name: name,
            shader: shader,
            graphics: graphics,
            uniforms: uniforms,
            arrayUniforms: [],
            emptyArrayUniform: EmptyUniforms(),
            vertexUniforms: cameraUniforms,
            vertices: vertices,
            metadata: metadata,
            options: options
        )
    }
    
    /// Vertex
    static func render<U, VU, G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U = EmptyUniforms(),
        vertexUniforms: VU = EmptyUniforms(),
        vertices: Vertices,
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
            vertices: vertices,
            metadata: metadata,
            options: options
        )
    }
    
    /// **Main** with static uniforms buffer
    private static func render<U, AU, VU, G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniforms: U,
        arrayUniforms: [AU],
        emptyArrayUniform: AU,
        vertexUniforms: VU,
        vertices: Vertices? = nil,
        metadata: Metadata? = nil,
        options: Options = Options()
    ) async throws -> G {
        var uniformsBuffer: MTLBuffer?
        if uniforms is EmptyUniforms == false {
            var uniforms: U = uniforms
            let size = MemoryLayout<U>.size
            guard let buffer = metalDevice.makeBuffer(bytes: &uniforms, length: size) else {
                throw RendererError.failedToMakeUniformBuffer
            }
            uniformsBuffer = buffer
        }
        
        var arrayUniformsBuffer: MTLBuffer?
        var activeArrayUniformsBuffer: MTLBuffer?
        if !arrayUniforms.isEmpty {
            
            var fixedArrayUniforms: [AU] = arrayUniforms
            var fixedActiveArrayUniforms: [Bool] = Array(repeating: true, count: arrayUniforms.count)
            
            if arrayUniforms.count <= Self.uniformArrayMaxLimit {
                for _ in arrayUniforms.count..<Self.uniformArrayMaxLimit {
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
            
            guard let buffer = metalDevice.makeBuffer(bytes: &fixedArrayUniforms, length: size) else {
                throw RendererError.failedToMakeArrayUniformBuffer
            }
            arrayUniformsBuffer = buffer
            
            guard let activeBuffer = metalDevice.makeBuffer(bytes: &fixedActiveArrayUniforms, length: activeSize) else {
                throw RendererError.failedToMakeArrayUniformBuffer
            }
            activeArrayUniformsBuffer = activeBuffer
        }
        
        let hasVertices: Bool = vertexUniforms is EmptyUniforms == false
        
        var vertexUniformsBuffer: MTLBuffer?
        if hasVertices {
            var uniforms: VU = vertexUniforms
            let size = MemoryLayout<VU>.size
            guard let buffer = metalDevice.makeBuffer(bytes: &uniforms, length: size) else {
                throw RendererError.failedToMakeVertexUniformBuffer
            }
            vertexUniformsBuffer = buffer
        }
        
        return try await render(
            name: name,
            shader: shader,
            graphics: graphics,
            uniformsBuffer: uniformsBuffer,
            arrayUniformsBuffer: arrayUniformsBuffer,
            activeArrayUniformsBuffer: activeArrayUniformsBuffer,
            vertexUniformsBuffer: vertexUniformsBuffer,
            vertices: vertices,
            metadata: metadata,
            options: options
        )
    }
    
    /// **Main**
    static func render<G: Graphicable>(
        name: String,
        shader: Shader,
        graphics: [Graphicable] = [],
        uniformsBuffer: MTLBuffer? = nil,
        arrayUniformsBuffer: MTLBuffer? = nil,
        activeArrayUniformsBuffer: MTLBuffer? = nil,
        vertexUniformsBuffer: MTLBuffer? = nil,
        vertices: Vertices? = nil,
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
        
        let sampleCount: Int = options.sampleCount
        
        let is3D: Bool = resolution is Size3D
        
        let optimization: Optimization = await optimization
        
        guard let commandQueue: MTLCommandQueue = await commandQueue() else {
            throw RendererError.failedToMakeCommandQueue
        }
        
        func makeTargetTexture() throws -> MTLTexture {
            if let resolution: CGSize = resolution as? CGSize {
                return try .empty(
                    resolution: resolution,
                    bits: bits,
                    sampleCount: sampleCount)
            } else if let resolution: Size3D = resolution as? Size3D {
                return try .empty3d(
                    resolution: resolution,
                    bits: bits,
                    usage: .write)
            }
            fatalError("Unknown Graphicable")
        }
        
        let targetTexture: MTLTexture
        if options.targetSourceTexture {
            guard let texture: MTLTexture = graphics.first?.texture else {
                throw RendererError.noTargetTextureFound
            }
            if texture.usage.contains(.renderTarget) {
                targetTexture = texture
            } else {
                print("AsyncGraphics - Renderer - Warning: Target source texture's render target usage not present. Falling back to new texture.")
                targetTexture = try makeTargetTexture()
            }
        } else {
            targetTexture = try makeTargetTexture()
        }
        var depthTexture: MTLTexture?
        if options.depth, let size = resolution as? CGSize {
            
            let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: options.stencil ? .depth32Float_stencil8 : .depth32Float,
                width: Int(size.width),
                height: Int(size.height),
                mipmapped: false)
            
            depthTextureDescriptor.usage = [.renderTarget, .shaderRead]

            depthTexture = metalDevice.makeTexture(descriptor: depthTextureDescriptor)
        }
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw RendererError.failedToMakeCommandBuffer
        }
        let commandEncoder: MTLCommandEncoder
        if !is3D {
            let renderCommandEncoder: MTLRenderCommandEncoder = try self.commandEncoder(
                texture: targetTexture,
                depthTexture: depthTexture,
                clearColor: options.clearColor,
                commandBuffer: commandBuffer)
            commandEncoder = renderCommandEncoder
        } else {
            guard let computeCommandEncoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
                throw RendererError.failedToMakeComputeCommandEncoder
            }
            commandEncoder = computeCommandEncoder
        }
        do {
        
            // MARK: Pipeline
            
            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                let pipeline: MTLRenderPipelineState = try await pipeline(
                    proxy: PipelineProxy(
                        shader: shader,
                        additive: options.additive,
                        depth: options.depth,
                        stencil: options.stencil,
                        bits: bits,
                        sampleCount: sampleCount
                    )
                )
                renderCommandEncoder.setRenderPipelineState(pipeline)
                if options.depth {
                    
                    let depthStateDescriptor = MTLDepthStencilDescriptor()
                    depthStateDescriptor.depthCompareFunction = .less
                    depthStateDescriptor.isDepthWriteEnabled = true
                    
                    let depthState: MTLDepthStencilState = metalDevice.makeDepthStencilState(descriptor: depthStateDescriptor)!

                    renderCommandEncoder.setDepthStencilState(depthState)
                }
                
            } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                
                let pipeline3d: MTLComputePipelineState = try await pipeline3d(
                    proxy: Pipeline3DProxy(
                        shader: shader
                    )
                )
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
                        
                    } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                        
                        computeCommandEncoder.setTexture(arrayTexture, index: 1)
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
                
                let sampler: MTLSamplerState = try sampler(addressMode: options.addressMode,
                                                           filter: options.filter)
                
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

            if let uniformsBuffer {
                
                if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                    
                    renderCommandEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
                    
                } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                    
                    computeCommandEncoder.setBuffer(uniformsBuffer, offset: 0, index: 0)
                }
            }
            // MARK: Array Uniforms
            
            if let arrayUniformsBuffer, let activeArrayUniformsBuffer {
               
                if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                    
                    renderCommandEncoder.setFragmentBuffer(arrayUniformsBuffer, offset: 0, index: 1)
                    renderCommandEncoder.setFragmentBuffer(activeArrayUniformsBuffer, offset: 0, index: 2)
                    
                } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                    
                    computeCommandEncoder.setBuffer(arrayUniformsBuffer, offset: 0, index: 1)
                    computeCommandEncoder.setBuffer(activeArrayUniformsBuffer, offset: 0, index: 2)
                }
            }
            // MARK: Vertex Uniforms
            
            if let vertexUniformsBuffer {
                
                if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                    
                    renderCommandEncoder.setVertexBuffer(vertexUniformsBuffer, offset: 0, index: 1)
                }
            }
            // MARK: Vertex
            
            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
                
                let vertexBuffer: MTLBuffer
                if let vertices {
                    switch vertices {
                    case .direct(let vertices, _):
                        vertexBuffer = try buffer(vertices: vertices)
                    case .indirect(let count, _):
                        vertexBuffer = try buffer(count: count)
                    }
                } else {
                    if optimization.contains(.cacheQuadVertexBuffer),
                       let buffer = storedVertexQuadBuffer {
                        vertexBuffer = buffer
                    } else {
                        vertexBuffer = try makeVertexQuadBuffer()
                    }
                }
                
                renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            }
            // MARK: Draw
            
            if let renderCommandEncoder = commandEncoder as? MTLRenderCommandEncoder {
             
                renderCommandEncoder.drawPrimitives(type: vertices?.type ?? .triangle,
                                                    vertexStart: 0,
                                                    vertexCount: vertices?.count ?? 6,
                                                    instanceCount: 1)
                
            } else if let computeCommandEncoder = commandEncoder as? MTLComputeCommandEncoder {
                
                guard let resolution: Size3D = resolution as? Size3D else {
                    fatalError("Non 3D Compute Encoding Not Supported")
                }
                
                let threadsPerThreadGroup = MTLSize(width: 8,
                                                    height: 8,
                                                    depth: 8)
                
                let threadsPerGrid: MTLSize = MTLSize(width: Int(resolution.width),
                                                      height: Int(resolution.height),
                                                      depth: Int(resolution.depth))
                
                computeCommandEncoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
            }
            commandEncoder.endEncoding()
            
        } catch {
            commandEncoder.endEncoding()
            throw error
        }
        
        try Task.checkCancellation()
        
        // MARK: Render
        var graphic: G = try await withCheckedThrowingContinuation { continuation in
        
            commandBuffer.addCompletedHandler { _ in
                
                let graphic = G(id: UUID(),
                                name: name,
                                texture: targetTexture,
                                bits: bits,
                                colorSpace: colorSpace)
                
                continuation.resume(returning: graphic)
            }
            
            commandBuffer.commit()
        }
        if sampleCount > 1 {
            
            let graphic2d = graphic as! Graphic
            graphic = try await graphic2d.downSample() as! G
        }
        try Task.checkCancellation()
        
        return graphic
    }
}
