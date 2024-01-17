//
//  Created by Anton Heestand on 2022-09-12.
//

import Metal
import MetalPerformanceShaders
import Spatial
import CoreGraphics
import CoreGraphicsExtensions
import SwiftUI
import TextureMap

extension Graphic3D {
    
    private struct LumaRainbowBlur3DUniforms {
        let type: UInt32
        let placement: UInt32
        let count: UInt32
        let radius: Float
        let angle: Float
        let light: Float
        let lumaGamma: Float
        let position: VectorUniform
    }
    
    @EnumMacro
    public enum LumaRainbowBlur3DType: String, GraphicEnum {
        case circle
        case zoom
    }
    
    public func lumaRainbowBlurredCircle(
        with graphic: Graphic3D,
        radius: CGFloat,
        angle: Angle = .zero,
        light: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaRainbowBlurred(
            with: graphic,
            type: .circle,
            radius: radius,
            angle: angle,
            light: light,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaRainbowBlurredZoom(
        with graphic: Graphic3D,
        radius: CGFloat,
        position: Point3D? = nil,
        light: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaRainbowBlurred(
            with: graphic,
            type: .zoom,
            radius: radius,
            position: position,
            light: light,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaRainbowBlurred(
        with graphic: Graphic3D,
        type: LumaRainbowBlur3DType,
        radius: CGFloat,
        position: Point3D? = nil,
        angle: Angle = .zero,
        light: CGFloat = 1.0,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition: Point3D = (position - resolution / 2) / height
        
        let relativeRadius: CGFloat = radius / height
        
        return try await Renderer.render(
            name: "Luma Rainbow Blur 3D",
            shader: .name("lumaRainbowBlur3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaRainbowBlur3DUniforms(
                type: type.index,
                placement: placement.index,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                angle: angle.uniform,
                light: Float(light),
                lumaGamma: Float(lumaGamma),
                position: relativePosition.uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}

