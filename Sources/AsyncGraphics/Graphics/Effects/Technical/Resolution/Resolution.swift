//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import TextureMap

extension Graphic {
    
    private struct ResolutionUniforms {
        let placement: Int32
        let outputResolution: SizeUniform
    }
    
    #warning("Switch Size to Resolution")
    
    public func resized(to size: CGSize, placement: Placement = .fit) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Resolution",
            shader: .name("resolution"),
            graphics: [self],
            uniforms: ResolutionUniforms(
                placement: Int32(placement.index),
                outputResolution: size.resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: size.resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
    
    public enum ResizeMethod {
        case lanczos
        case bilinear
    }
    
    public func resizedStretched(to size: CGSize, method: ResizeMethod = .lanczos) async throws -> Graphic {
        
        let resolution: CGSize = size.resolution

        let targetTexture: MTLTexture = try await TextureMap.emptyTexture(resolution: resolution, bits: bits, usage: .write)
        
        guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else {
            throw Renderer.RendererError.failedToMakeCommandQueue
        }
        
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw Renderer.RendererError.failedToMakeCommandBuffer
        }
        
        let scaleKernel: MPSImageScale
        switch method {
        case .lanczos:
            scaleKernel = MPSImageLanczosScale(device: Renderer.metalDevice)
        case .bilinear:
            scaleKernel = MPSImageBilinearScale(device: Renderer.metalDevice)
        }
        scaleKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: targetTexture)
        
        let _: Void = await withCheckedContinuation { continuation in
            
            commandBuffer.addCompletedHandler { _ in
                
                continuation.resume()
            }
            
            commandBuffer.commit()
        }
        
        return Graphic(name: "Resolution", texture: targetTexture, bits: bits, colorSpace: colorSpace)
        
    }
}
