//
//  Created by Anton Heestand on 2023-12-07.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    private struct SampleLineUniforms {
        let sampleDistance: Float
        let leadingPoint: PointUniform
        let trailingPoint: PointUniform
        let leadingAngle: Float
        let trailingAngle: Float
        let tintColor: ColorUniform
        let backgroundColor: ColorUniform
        let blendingMode: UInt32
        let resolution: SizeUniform
    }
    
    public static func sampleLine(
        with graphic: Graphic,
        form leadingPoint: CGPoint,
        to trailingPoint: CGPoint,
        fromAngle leadingAngle: Angle? = nil,
        toAngle trailingAngle: Angle? = nil,
        count: Int,
        blendingMode: BlendMode = .over,
        tintColor: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        resolution: CGSize,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let distance: CGFloat = hypot(trailingPoint.x - leadingPoint.x,
                                      trailingPoint.y - leadingPoint.y)
        
        let sampleDistance: CGFloat = distance / CGFloat(count)
        
        return try await sampleLine(
            with: graphic,
            form: leadingPoint,
            to: trailingPoint,
            fromAngle: leadingAngle,
            toAngle: trailingAngle,
            sampleDistance: sampleDistance,
            blendingMode: blendingMode,
            tintColor: tintColor,
            backgroundColor: backgroundColor,
            resolution: resolution,
            options: options
        )
    }
    
    public static func sampleLine(
        with graphic: Graphic,
        form leadingPoint: CGPoint,
        to trailingPoint: CGPoint,
        fromAngle leadingAngle: Angle? = nil,
        toAngle trailingAngle: Angle? = nil,
        sampleDistance: CGFloat,
        blendingMode: BlendMode = .over,
        tintColor: PixelColor = .white,
        backgroundColor: PixelColor = .black,
        resolution: CGSize,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let relativeLeadingPoint: CGPoint = (leadingPoint - resolution / 2) / resolution.height
        let relativeTrailingPoint: CGPoint = (trailingPoint - resolution / 2) / resolution.height
        
        let angle: Angle = .radians(atan2(
            trailingPoint.y - leadingPoint.y,
            trailingPoint.x - leadingPoint.x
        ))
        let leadingAngle: Angle = leadingAngle ?? angle
        let trailingAngle: Angle = trailingAngle ?? angle
        
        let relativeSampleDistance: CGFloat = sampleDistance / resolution.height
        
        return try await Renderer.render(
            name: "Sample Line",
            shader: .name("sampleLine"),
            graphics: [graphic],
            uniforms: SampleLineUniforms(
                sampleDistance: Float(relativeSampleDistance),
                leadingPoint: relativeLeadingPoint.uniform,
                trailingPoint: relativeTrailingPoint.uniform,
                leadingAngle: Float(leadingAngle.radians),
                trailingAngle: Float(trailingAngle.radians),
                tintColor: tintColor.uniform,
                backgroundColor: backgroundColor.uniform,
                blendingMode: blendingMode.index,
                resolution: resolution.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: graphic.colorSpace,
                bits: graphic.bits
            ),
            options: options.spatialRenderOptions
        )
    }
}
