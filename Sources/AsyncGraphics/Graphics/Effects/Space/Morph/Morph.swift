//
//  Created by Anton Heestand on 2022-09-13.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI
import TextureMap

extension Graphic {
    
    public func morphedMinimum(size: CGSize) async throws -> Graphic {
        
        try await morphed(type: .minimum, size: size)
    }
    
    public func morphedMaximum(size: CGSize) async throws -> Graphic {
        
        try await morphed(type: .maximum, size: size)
    }
    
    @EnumMacro
    public enum MorphType: String, GraphicEnum {
        case minimum
        case maximum
    }
    
    func morphed(type: MorphType, size: CGSize) async throws -> Graphic {
        
        let targetTexture: MTLTexture = try await .empty(resolution: resolution, bits: bits, usage: .write)
        
        guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else {
            throw Renderer.RendererError.failedToMakeCommandQueue
        }
        
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw Renderer.RendererError.failedToMakeCommandBuffer
        }
        
        let kernel: MPSUnaryImageKernel
        switch type {
        case .minimum:
            kernel = MPSImageAreaMin(
                device: Renderer.metalDevice,
                kernelWidth: 1 + max(Int(size.width), 0) * 2,
                kernelHeight: 1 + max(Int(size.height), 0) * 2
            )
        case .maximum:
            kernel = MPSImageAreaMax(
                device: Renderer.metalDevice,
                kernelWidth: 1 + max(Int(size.width), 0) * 2,
                kernelHeight: 1 + max(Int(size.height), 0) * 2
            )
        }
        kernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: targetTexture)

        let _: Void = await withCheckedContinuation { continuation in
            
            commandBuffer.addCompletedHandler { _ in
                
                continuation.resume()
            }
            
            commandBuffer.commit()
        }
        
        return Graphic(name: "Morph", texture: targetTexture, bits: bits, colorSpace: colorSpace)
    }
}

