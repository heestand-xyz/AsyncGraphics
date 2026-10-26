//
//  Created by Anton Heestand on 2022-04-22.
//

import SwiftUI
import Metal
import MetalPerformanceShaders
import Spatial
import CoreGraphics
import CoreGraphicsExtensions
import TextureMap

extension Graphic3D {
    
    private struct Blur3DUniforms: Uniforms {
        let type: UInt32
        let radius: Float
        let count: UInt32
        let direction: VectorUniform
        let position: VectorUniform
        let pureAlpha: UInt32
    }
    
    @EnumMacro
    public enum Blur3DType: String, GraphicEnum {
        case layered
        case box
        case direction
        case zoom
        case random
        var shaderIndex: UInt32 {
            switch self {
            case .layered:
                0 // Not used.
            case .box:
                0
            case .direction:
                1
            case .zoom:
                2
            case .random:
                3
            }
        }
    }
    
    public func blurredBox(
        radius: CGFloat,
        sampleCount: Int = 10,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let relativeRadius: CGFloat = radius / CGFloat(height)
        
        return try await Renderer.render(
            name: "Blur 3D (Box)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.box.shaderIndex,
                radius: Float(relativeRadius),
                count: UInt32(sampleCount),
                direction: VectorUniform.zero,
                position: VectorUniform.zero,
                pureAlpha: options.contains(.pureAlpha) ? 1 : 0
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public func blurredZoom(
        radius: CGFloat,
        position: Point3D? = nil,
        sampleCount: Int = 100,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition: Point3D = (position - resolution / 2) / height
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Blur 3D (Zoom)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.zoom.shaderIndex,
                radius: Float(relativeRadius),
                count: UInt32(sampleCount),
                direction: VectorUniform.zero,
                position: relativePosition.uniform,
                pureAlpha: options.contains(.pureAlpha) ? 1 : 0
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public func blurredDirection(
        radius: CGFloat,
        direction: Point3D,
        sampleCount: Int = 100,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let relativeRadius: CGFloat = radius / CGFloat(height)
        
        return try await Renderer.render(
            name: "Blur 3D (Angle)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.direction.shaderIndex,
                radius: Float(relativeRadius),
                count: UInt32(sampleCount),
                direction: direction.uniform,
                position: VectorUniform.zero,
                pureAlpha: options.contains(.pureAlpha) ? 1 : 0
            ),
            options: options.spatialRenderOptions
        )
    }
    
    public func blurredRandom(
        radius: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let relativeRadius: CGFloat = radius / CGFloat(height)
        
        return try await Renderer.render(
            name: "Blur 3D (Random)",
            shader: .name("blur3d"),
            graphics: [self],
            uniforms: Blur3DUniforms(
                type: Blur3DType.random.shaderIndex,
                radius: Float(relativeRadius),
                count: 0,
                direction: VectorUniform.zero,
                position: VectorUniform.zero,
                pureAlpha: options.contains(.pureAlpha) ? 1 : 0
            ),
            options: options.spatialRenderOptions
        )
    }
}
