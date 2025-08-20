//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics
import SwiftUI

extension Graphic3D {
    
    private struct Polar3DUniforms: Uniforms {
        let radius: Float
    }
    
    public func polar(radius: CGFloat? = nil,
                      resolution: CGSize? = nil,
                      options: Graphic.EffectOptions = []) async throws -> Graphic {
        
        let relativeRadius: CGFloat = (radius ?? height / 2) / (height / 2)
        let autoHeight: CGFloat = round((height / 2) * .pi * relativeRadius)
        let resolution: CGSize = resolution ?? CGSize(width: autoHeight * 2, height: autoHeight)
        
        return try await Renderer.render(
            name: "Polar 3D",
            shader: .name("polar3d"),
            graphics: [self],
            uniforms: Polar3DUniforms(
                radius: Float(relativeRadius)
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
