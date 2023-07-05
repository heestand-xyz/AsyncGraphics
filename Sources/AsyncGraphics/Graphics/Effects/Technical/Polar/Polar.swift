//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import SwiftUI

extension Graphic {
    
    private struct PolarUniforms {
        let radius: Float
        let width: Float
        let leadingAngle: Float
        let trailingAngle: Float
    }
    
    public func polar(radius: CGFloat? = nil,
                      width: CGFloat? = nil,
                      leadingAngle: Angle,
                      trailingAngle: Angle,
                      resolution: CGSize,
                      options: EffectOptions = []) async throws -> Graphic {
        
        let relativeRadius: CGFloat = (radius ?? height / 2) / height
        let relativeWidth: CGFloat = (width ?? height / 4) / height
        
        return try await Renderer.render(
            name: "Polar",
            shader: .name("polar"),
            graphics: [self],
            uniforms: PolarUniforms(
                radius: Float(relativeRadius),
                width: Float(relativeWidth),
                leadingAngle: leadingAngle.uniform,
                trailingAngle: trailingAngle.uniform
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
