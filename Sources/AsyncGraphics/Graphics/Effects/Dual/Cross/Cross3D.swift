//
//  Created by Anton Heestand on 2022-04-28.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Cross3DUniforms {
        let fraction: Float
        let placement: Int32
    }
    
    public func cross(with graphic: Graphic3D,
                      fraction: CGFloat,
                      placement: Placement = .fit) async throws -> Graphic3D {
        try await cross(fraction: fraction, placement: placement) {
            graphic
        }
    }
    
    @available(*, deprecated, renamed: "cross(with:fraction:placement:)")
    public func cross(fraction: CGFloat,
                      placement: Placement = .fit,
                      graphic: () async throws -> Graphic3D) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Cross 3D",
            shader: .name("cross3d"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: Cross3DUniforms(
                fraction: Float(fraction),
                placement: Int32(placement.index)
            )
        )
    }
}