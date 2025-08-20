//
//  Created by Anton Heestand on 2022-04-07.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI
import TextureMap

extension Graphic {
    
    private struct BlurUniforms: Uniforms {
        let type: UInt32
        let radius: Float
        let count: UInt32
        let angle: Float
        let position: PointUniform
    }
    
    @EnumMacro
    public enum BlurType: String, GraphicEnum {
        case gaussian
        case box
        case angle
        case zoom
        case random
        case layered
    }
    
    /// Gaussian Blur
    public func blurred(
        radius: CGFloat
    ) async throws -> Graphic {
        
        let targetTexture: MTLTexture = try .empty(resolution: resolution, bits: bits, usage: .write)
        
        guard let commandQueue = Renderer.metalDevice.makeCommandQueue() else {
            throw Renderer.RendererError.failedToMakeCommandQueue
        }
        
        guard let commandBuffer: MTLCommandBuffer = commandQueue.makeCommandBuffer() else {
            throw Renderer.RendererError.failedToMakeCommandBuffer
        }
        
        let gaussianBlurKernel = MPSImageGaussianBlur(device: Renderer.metalDevice, sigma: Float(radius))
        gaussianBlurKernel.edgeMode = .clamp
        gaussianBlurKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: targetTexture)
        
        let _: Void = await withCheckedContinuation { continuation in
            
            commandBuffer.addCompletedHandler { _ in
                
                continuation.resume()
            }
            
            commandBuffer.commit()
        }
        
        return Graphic(
            name: "Blur (Gaussian)",
            texture: targetTexture,
            bits: bits,
            colorSpace: colorSpace
        )
    }
    
    public func blurredLayered(
        radius: CGFloat,
        layerCount: Int = 10,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        if layerCount < 1 { return self }
        var blurredGraphic: Graphic = self
        var radius: CGFloat = radius
        for _ in 0..<layerCount {
            blurredGraphic = try await blurredGraphic.blurredLayeredSinglePass(radius: radius, options: options)
            radius /= 2.0
        }
        return blurredGraphic
    }
    
    public func blurredLayeredSinglePass(
        radius: CGFloat,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Layered)",
            shader: .name("blur"),
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.layered.index,
                radius: Float(relativeRadius),
                count: 1,
                angle: 0.0,
                position: CGPoint.zero.uniform
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public func blurredBox(
        radius: CGFloat,
        sampleCount: Int = 100,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Box)",
            shader: .name("blur"),
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.box.index,
                radius: Float(relativeRadius),
                count: UInt32(sampleCount),
                angle: 0.0,
                position: CGPoint.zero.uniform
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public func blurredZoom(
        radius: CGFloat,
        position: CGPoint? = nil,
        sampleCount: Int = 100,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        let position: CGPoint = position ?? resolution.asPoint / 2
        let relativePosition: CGPoint = (position - resolution / 2) / height
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Zoom)",
            shader: .name("blur"),
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.zoom.index,
                radius: Float(relativeRadius),
                count: UInt32(sampleCount),
                angle: 0.0,
                position: relativePosition.uniform
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public func blurredAngle(
        radius: CGFloat,
        angle: Angle,
        sampleCount: Int = 100,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Angle)",
            shader: .name("blur"),
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.angle.index,
                radius: Float(relativeRadius),
                count: UInt32(sampleCount),
                angle: angle.uniform,
                position: CGPoint.zero.uniform
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public func blurredRandom(
        radius: CGFloat,
        options: EffectOptions = [.edgeStretch]
    ) async throws -> Graphic {
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur (Random)",
            shader: .name("blur"),
            graphics: [self],
            uniforms: BlurUniforms(
                type: BlurType.random.index,
                radius: Float(relativeRadius),
                count: 0,
                angle: 0.0,
                position: CGPoint.zero.uniform
            ),
            options: options.spatialRenderOptions
        )
    }
}

