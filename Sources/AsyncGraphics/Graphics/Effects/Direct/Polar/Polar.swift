//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import SwiftUI

extension Graphic {
    
    private struct EdgeUniforms {
        let radius: Float
        let width: Float
        let leadingAngle: Float
        let trailingAngle: Float
    }
    
    public func polar(radius: CGFloat? = nil,
                      width: CGFloat? = nil,
                      leadingAngle: Angle = .degrees(90),
                      trailingAngle: Angle = .degrees(450),
                      resolution: CGSize,
                      options: EffectOptions = EffectOptions()) async throws -> Graphic {
        
        let relativeRadius: CGFloat = (radius ?? resolution.height / 2) / resolution.height
        let relativeWidth: CGFloat = (width ?? resolution.height / 4) / resolution.height
        
        return try await Renderer.render(
            name: "Polar",
            shader: .name("polar"),
            graphics: [self],
            uniforms: EdgeUniforms(
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
                addressMode: options.addressMode
            )
        )
    }
}
