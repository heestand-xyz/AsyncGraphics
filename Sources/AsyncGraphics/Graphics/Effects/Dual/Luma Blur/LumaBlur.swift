//
//  Created by Anton Heestand on 2022-09-10.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions

extension Graphic {
    
    private struct LumaBlurUniforms {
        let type: UInt32
        let placement: UInt32
        let count: UInt32
        let radius: Float
        let position: PointUniform
        let angle: Float
        let lumaGamma: Float
    }
   
    private enum LumaBlurType: UInt32 {
        case box
        case angle
        case zoom
        case random
    }
    
    // TODO: Implement Core Image Version
//    enum LumaBlurError: LocalizedError {
//        case filterNotFound
//    }
//    
//    public func lumaBlurred(
//        with graphic: Graphic,
//        radius: CGFloat
//    ) async throws -> Graphic {
//        guard let maskedVariableBlur = CIFilter(name: "CIMaskedVariableBlur") else {
//            throw LumaBlurError.filterNotFound
//        }
//        maskedVariableBlur.setValue(inputImage, forKey: kCIInputImageKey)
//        maskedVariableBlur.setValue(10, forKey: kCIInputRadiusKey)
//        maskedVariableBlur.setValue(radialMask.outputImage, forKey: "inputMask")
//        let selectivelyFocusedCIImage = maskedVariableBlur.outputImage
//    }
    
    public func lumaBlurredBox(
        with graphic: Graphic,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaBlurredBox(
            radius: radius,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaBlurredBox(with:radius:lumaGamma:sampleCount:placement:options:)")
    public func lumaBlurredBox(
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .box,
            radius: radius,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
 
    public func lumaBlurredZoom(
        with graphic: Graphic,
        radius: CGFloat,
        position: CGPoint? = nil,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaBlurredZoom(
            radius: radius,
            position: position,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaBlurredZoom(with:radius:position:lumaGamma:sampleCount:placement:options:)")
    public func lumaBlurredZoom(
        radius: CGFloat,
        position: CGPoint? = nil,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .zoom,
            radius: radius,
            position: position,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
    
    public func lumaBlurredAngle(
        with graphic: Graphic,
        radius: CGFloat,
        angle: Angle,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaBlurredAngle(
            radius: radius,
            angle: angle,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaBlurredAngle(with:radius:angle:lumaGamma:sampleCount:placement:options:)")
    public func lumaBlurredAngle(
        radius: CGFloat,
        angle: Angle,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .angle,
            radius: radius,
            angle: angle,
            lumaGamma: lumaGamma,
            sampleCount: sampleCount,
            placement: placement,
            options: options,
            graphic: graphic
        )
    }
    
    public func lumaBlurredRandom(
        with graphic: Graphic,
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await lumaBlurredRandom(
            radius: radius,
            lumaGamma: lumaGamma,
            placement: placement,
            options: options,
            graphic: { graphic }
        )
    }
    
    @available(*, deprecated, renamed: "lumaBlurredRandom(with:radius:lumaGamma:placement:options:)")
    public func lumaBlurredRandom(
        radius: CGFloat,
        lumaGamma: CGFloat = 1.0,
        placement: Placement = .fit,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await lumaBlurred(
            type: .random,
            radius: radius,
            options: options,
            graphic: graphic
        )
    }
    
    private func lumaBlurred(
        type: LumaBlurType,
        radius: CGFloat,
        position: CGPoint? = nil,
        angle: Angle = .zero,
        lumaGamma: CGFloat = 1.0,
        sampleCount: Int = 100,
        placement: Placement = .fit,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
            
        let relativeRadius: CGFloat = radius / height
       
        let position: CGPoint = position ?? resolution.asPoint / 2
        let relativePosition: CGPoint = (position - resolution / 2) / height
        
        return try await Renderer.render(
            name: "Luma Blur",
            shader: .name("lumaBlur"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: LumaBlurUniforms(
                type: type.rawValue,
                placement: placement.index,
                count: UInt32(sampleCount),
                radius: Float(relativeRadius),
                position: relativePosition.uniform,
                angle: angle.uniform,
                lumaGamma: Float(lumaGamma)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
