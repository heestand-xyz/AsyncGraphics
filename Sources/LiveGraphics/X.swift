//
//  MIBViewModel.swift
//  Metal Image Blending
//
//  Created by Anton Heestand on 2021-09-18.
//

import Foundation
import AppKit
import MetalKit

class MIBViewModel: ObservableObject {
    
    let metalDevice: MTLDevice = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Device Not Supported")
        }
        return device
    }()
    
    enum MIBError: Error {
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
    
    func blend(_ sourceImageA: NSImage, with sourceImageB: NSImage) throws -> NSImage {
        
        let sourceTextureA: MTLTexture = try texture(image: sourceImageA)
        let sourceTextureB: MTLTexture = try texture(image: sourceImageB)
        
        let destinationTexture: MTLTexture = try emptyTexture(size: CGSize(width: 1500, height: 1000))
        
        guard let commandQueue = metalDevice.makeCommandQueue() else {
            throw MIBError.commandQueue
        }
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw MIBError.commandBuffer
        }
        
        let commandEncoder: MTLRenderCommandEncoder = try commandEncoder(texture: destinationTexture, commandBuffer: commandBuffer)
        
        let pipeline: MTLRenderPipelineState = try pipeline()
        
        let sampler: MTLSamplerState = try sampler()
        
        let vertexBuffer: MTLBuffer = try vertexQuadBuffer()
        
        commandEncoder.setRenderPipelineState(pipeline)
        
        commandEncoder.setFragmentTexture(sourceTextureA, index: 0)
        commandEncoder.setFragmentTexture(sourceTextureB, index: 1)
        
        commandEncoder.setFragmentSamplerState(sampler, index: 0)
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let destinationImage: NSImage = try image(texture: destinationTexture)
        
        return destinationImage
    }
}

// MARK: - Texture

extension MIBViewModel {
    
    func texture(image: NSImage) throws -> MTLTexture {
        guard let cgImage: CGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw MIBError.textureCGImage
        }
        let loader = MTKTextureLoader(device: metalDevice)
        return try loader.newTexture(cgImage: cgImage, options: [.SRGB: false])
    }
    
    func emptyTexture(size: CGSize) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(size.width), height: Int(size.height), mipmapped: true)
        descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue)
        guard let texture = metalDevice.makeTexture(descriptor: descriptor) else {
            throw MIBError.emptyTexture
        }
        return texture
    }
}

// MARK: - Image

extension MIBViewModel {
    
    func image(texture: MTLTexture) throws -> NSImage {
        let size = CGSize(width: texture.width, height: texture.height)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let ciImage: CIImage = CIImage(mtlTexture: texture, options: [.colorSpace: colorSpace]),
              let cgImage: CGImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: .RGBA8, colorSpace: colorSpace)
        else {
            throw MIBError.image
        }
        return NSImage(cgImage: cgImage, size: size)
    }
}

// MARK: - Pipeline

extension MIBViewModel {
    
    func pipeline() throws -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = try shader(name: "vertexQuad")
        pipelineStateDescriptor.fragmentFunction = try shader(name: "imageBlending")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

// MARK: - Command Encoder

extension MIBViewModel {
    
    func commandEncoder(texture: MTLTexture, commandBuffer: MTLCommandBuffer) throws -> MTLRenderCommandEncoder {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder: MTLRenderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw MIBError.commandEncoder
        }
        return commandEncoder
    }
}

// MARK: - Sampler

extension MIBViewModel {
    
    func sampler() throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = .linear
        samplerInfo.magFilter = .linear
        samplerInfo.sAddressMode = .clampToZero
        samplerInfo.tAddressMode = .clampToZero
        samplerInfo.compareFunction = .never
        samplerInfo.mipFilter = .linear
        guard let sampler = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw MIBError.sampler
        }
        return sampler
    }
}

// MARK: - Vertex Quad

extension MIBViewModel {
    
    struct Vertex {
        let x, y: CGFloat
        let s, t: CGFloat
        var buffer: [Float] {
            [x, y, s, t].map(Float.init)
        }
    }
    
    public func vertexQuadBuffer() throws -> MTLBuffer {
        let a = Vertex(x: -1.0, y: -1.0, s: 0.0, t: 0.0)
        let b = Vertex(x: 1.0, y: -1.0, s: 1.0, t: 0.0)
        let c = Vertex(x: -1.0, y: 1.0, s: 0.0, t: 1.0)
        let d = Vertex(x: 1.0, y: 1.0, s: 1.0, t: 1.0)
        let vertices: [Vertex] = [a, b, c, b, c, d]
        let vertexBuffer: [Float] = vertices.flatMap(\.buffer)
        let dataSize = vertexBuffer.count * MemoryLayout.size(ofValue: vertexBuffer[0])
        guard let buffer = metalDevice.makeBuffer(bytes: vertexBuffer, length: dataSize, options: []) else {
            throw MIBError.vertexQuadBuffer
        }
        return buffer
    }
}

// MARK: - Shader

extension MIBViewModel {
    
    func shader(name: String) throws -> MTLFunction {
        let metalLibrary: MTLLibrary = try metalDevice.makeDefaultLibrary(bundle: Bundle.main)
        guard let shader = metalLibrary.makeFunction(name: name) else {
            throw MIBError.shaderFunction
        }
        return shader
    }
}
