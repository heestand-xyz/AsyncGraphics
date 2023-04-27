//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal

extension Graphic3D {
    
    private struct Blend3DUniforms {
        let blendingMode: Int32
        let placement: Int32
    }
    
    @available(*, deprecated, renamed: "blended(blendingMode:placement:graphic:)")
    public func blended(with graphic: Graphic3D,
                        blendingMode: AGBlendMode,
                        placement: Placement = .fit) async throws -> Graphic3D {
        try await blended(blendingMode: blendingMode, placement: placement) {
            graphic
        }
    }
    
    public func blended(
        blendingMode: AGBlendMode,
        placement: Placement = .fit,
        graphic: () async throws -> Graphic3D
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Blend",
            shader: .name("blend3d"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: Blend3DUniforms(
                blendingMode: Int32(blendingMode.index),
                placement: Int32(placement.index)
            )
        )
    }
}
