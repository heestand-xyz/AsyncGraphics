//
//  Created by Anton Heestand on 2022-04-06.
//

import CoreGraphics
import Metal
import PixelColor

extension Graphic {
    
    private struct DisplaceUniforms {
        let offset: Float
        let origin: PointUniform
        let placement: UInt32
    }
    
    public func displaced(with graphic: Graphic,
                          offset: CGFloat,
                          origin: PixelColor = .rawGray,
                          placement: Placement = .fill,
                          options: EffectOptions = []) async throws -> Graphic {
        
        let relativeOffset: CGFloat = offset / resolution.height
        
        return try await Renderer.render(
            name: "Displace",
            shader: .name("displace"),
            graphics: [
                self,
                graphic
            ],
            uniforms: DisplaceUniforms(
                offset: Float(relativeOffset),
                origin: PointUniform(
                    x: Float(origin.red),
                    y: Float(origin.green)
                ),
                placement: placement.index
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
