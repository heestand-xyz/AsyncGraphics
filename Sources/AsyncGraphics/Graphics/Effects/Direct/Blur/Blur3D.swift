//
//  Created by Anton Heestand on 2022-04-22.
//

import Metal
import MetalPerformanceShaders
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI
import TextureMap

extension Graphic3D {
    
    private struct Blur3DUniforms {
        let type: Int32
        let radius: Float
        let count: Int32
        let direction: VectorUniform
        let position: VectorUniform
    }
    
    private enum Blur3DType: Int32 {
        case box
        case direction
        case zoom
        case random
    }
    
    public func blurredBox(radius: CGFloat,
                           sampleCount: Int = 10,
                           options: EffectOptions = []) async throws -> Graphic3D {
        
        let relativeRadius: CGFloat = radius / CGFloat(height)
        
        return try await Renderer.render(
            name: "Blur (Box)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.box.rawValue,
                radius: Float(relativeRadius),
                count: Int32(sampleCount),
                direction: VectorUniform.zero,
                position: VectorUniform.zero
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
    
    public func blurredZoom(radius: CGFloat,
                            center: SIMD3<Double>? = nil,
                            sampleCount: Int = 100,
                            options: EffectOptions = []) async throws -> Graphic3D {
        
        let center: SIMD3<Double> = center ?? resolution.asDouble / 2
        let relativeCenter: SIMD3<Double> = (center - resolution.asDouble / 2) / Double(height)
        
        let relativeRadius: CGFloat = radius / CGFloat(height)
        
        return try await Renderer.render(
            name: "Blur (Zoom)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.zoom.rawValue,
                radius: Float(relativeRadius),
                count: Int32(sampleCount),
                direction: VectorUniform.zero,
                position: relativeCenter.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
    
    public func blurredDirection(radius: CGFloat,
                                 direction: SIMD3<Double>,
                                 sampleCount: Int = 100,
                                 options: EffectOptions = []) async throws -> Graphic3D {
        
        let relativeRadius: CGFloat = radius / CGFloat(height)
        
        return try await Renderer.render(
            name: "Blur (Angle)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.direction.rawValue,
                radius: Float(relativeRadius),
                count: Int32(sampleCount),
                direction: direction.uniform,
                position: VectorUniform.zero
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
    
    public func blurredRandom(radius: CGFloat,
                              options: EffectOptions = []) async throws -> Graphic3D {
        
        let relativeRadius: CGFloat = radius / CGFloat(height)
        
        return try await Renderer.render(
            name: "Blur (Random)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.random.rawValue,
                radius: Float(relativeRadius),
                count: 0,
                direction: VectorUniform.zero,
                position: VectorUniform.zero
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}

