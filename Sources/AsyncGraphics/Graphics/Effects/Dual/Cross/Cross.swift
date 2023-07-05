//
//  Created by Anton Heestand on 2022-04-19.
//

import CoreGraphics

extension Graphic {
    
    private struct CrossUniforms {
        let fraction: Float
        let placement: Int32
    }
    
//    @available(*, deprecated, renamed: "cross(fraction:placement:options:graphic:)")
    public func cross(with graphic: Graphic,
                      fraction: CGFloat,
                      placement: Placement = .fit,
                      options: EffectOptions = []) async throws -> Graphic {
        try await cross(fraction: fraction, placement: placement, options: options) {
            graphic
        }
    }
    
    public func cross(fraction: CGFloat,
                      placement: Placement = .fit,
                      options: EffectOptions = [],
                      graphic: () async throws -> Graphic) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Cross",
            shader: .name("cross"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: CrossUniforms(
                fraction: Float(fraction),
                placement: Int32(placement.index)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
