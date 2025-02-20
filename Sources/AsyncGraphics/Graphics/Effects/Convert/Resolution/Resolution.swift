//
//  Created by Anton Heestand on 2022-04-21.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import TextureMap
import CoreGraphicsExtensions

extension Graphic {
    
    private struct ResolutionUniforms {
        let placement: Int32
        let outputResolution: SizeUniform
    }
    
    public func resized(
        in resolution: CGSize,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let relativeWidth: CGFloat = width / resolution.width
        let relativeHeight: CGFloat = height / resolution.height
        
        let derivedResolution = CGSize(
            width: relativeWidth > relativeHeight ? resolution.width : width * (resolution.height / height),
            height: relativeWidth < relativeHeight ? resolution.height : height * (resolution.width / width)
        )
        
        return try await self.resized(
            to: derivedResolution,
            placement: .stretch,
            options: options
        )
    }
    
    @EnumMacro
    public enum ResolutionInterpolation: String, GraphicEnum {
        case linear
        case lanczos
        case bilinear
        case pixelated
    }
    
    public func resized(
        to resolution: CGSize,
        placement: Placement = .fit,
        interpolation: ResolutionInterpolation,
        options: EffectOptions = []
    ) async throws -> Graphic {
        switch interpolation {
        case .linear:
            return try await resized(to: resolution, placement: placement, options: options)
        case .lanczos:
            return try await resized(to: resolution, placement: placement, method: .lanczos)
        case .bilinear:
            return try await resized(to: resolution, placement: placement, method: .bilinear)
        case .pixelated:
            var options: EffectOptions = options
            options.insert(.interpolateNearest)
            return try await resized(to: resolution, placement: placement, options: options)
        }
    }
    
    public func resized(
        to resolution: CGSize,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Resolution",
            shader: .name("resolution"),
            graphics: [self],
            uniforms: ResolutionUniforms(
                placement: Int32(placement.index),
                outputResolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public enum ResizeMethod: Sendable {
        case lanczos
        case bilinear
    }
    
    public func resized(
        to resolution: CGSize,
        placement: Placement = .fit,
        method: ResizeMethod
    ) async throws -> Graphic {
        let placeResolution = self.resolution.place(in: resolution, placement: placement.sizePlacement)
        return try await resizedStretched(to: placeResolution, method: method)
            .resized(to: resolution, placement: placement)
    }
    
    enum ResizeError: Error {
        case resolutionToLow
    }
    
    public func resizedStretched(
        to resolution: CGSize,
        method: ResizeMethod
    ) async throws -> Graphic {
        
        guard resolution.width > 1, resolution.height > 1 else {
            throw ResizeError.resolutionToLow
        }

        let targetTexture: MTLTexture = try .empty(resolution: resolution, bits: bits, usage: .write)
        
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

extension Graphic {
    
    public func resized(by multiplier: CGFloat) async throws -> Graphic {

        try await resized(to: resolution * multiplier)
    }
}
