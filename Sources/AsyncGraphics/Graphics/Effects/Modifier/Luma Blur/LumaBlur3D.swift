//
//  Created by Anton Heestand on 2022-09-10.
//

import SwiftUI
import Spatial
import CoreGraphics
import CoreGraphicsExtensions

extension Graphic3D {
    
    private struct LumaBlur3DUniforms {
        let type: UInt32
        let placement: UInt32
        let count: UInt32
        let radius: Float
        let position: VectorUniform
        let lumaGamma: Float
    }
   
    @EnumMacro
    public enum LumaBlur3DType: String, GraphicEnum {
        case box
        case zoom
        case random
    }
    
    public func lumaBlurredBox(
        with graphic: Graphic3D,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 10,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaBlurred(
            with: graphic,
            type: .box,
            radius: radius,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
 
    public func lumaBlurredZoom(
        with graphic: Graphic3D,
        radius: CGFloat,
        position: Point3D? = nil,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 10,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaBlurred(
            with: graphic,
            type: .zoom,
            radius: radius,
            position: position,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options
        )
    }
    
    public func lumaBlurredRandom(
        with graphic: Graphic3D,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaBlurred(
            with: graphic,
            type: .random,
            radius: radius,
            options: options
        )
    }
    
    private func lumaBlurred(
        with graphic: Graphic3D,
        type: LumaBlur3DType,
        radius: CGFloat,
        position: Point3D? = nil,
        angle: Angle = .zero,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 10,
        placement: Graphic.Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
            
        let relativeRadius: CGFloat = radius / height
       
        let position: Point3D = position ?? Point3D(resolution) / 2
        let relativePosition: Point3D = (position - resolution / 2) / height
        
        return try await Renderer.render(
            name: "Luma Blur 3D",
            shader: .name("lumaBlur3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaBlur3DUniforms(
                type: type.index,
                placement: placement.index,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}
