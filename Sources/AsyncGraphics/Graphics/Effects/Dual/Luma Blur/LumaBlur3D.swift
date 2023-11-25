//
//  Created by Anton Heestand on 2022-09-10.
//

import SwiftUI
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
   
    private enum LumaBlur3DType: UInt32 {
        case box
        case zoom
        case random
    }
    
    public func lumaBlurredBox(
        with graphic: Graphic3D,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 10,
        placement: Placement = .fit,
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
        center: SIMD3<Double>? = nil,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 10,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await lumaBlurred(
            with: graphic,
            type: .zoom,
            radius: radius,
            center: center,
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
        placement: Placement = .fit,
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
        center: SIMD3<Double>? = nil,
        angle: Angle = .zero,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 10,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
            
        let relativeRadius: CGFloat = radius / CGFloat(height)
       
        let center: SIMD3<Double> = center ?? SIMD3<Double>(resolution) / 2
        let relativeCenter: SIMD3<Double> = (center - SIMD3<Double>(resolution) / 2) / Double(height)
        
        return try await Renderer.render(
            name: "Luma Blur 3D",
            shader: .name("lumaBlur3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: LumaBlur3DUniforms(
                type: type.rawValue,
                placement: placement.index,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                position: relativeCenter.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode
            )
        )
    }
}