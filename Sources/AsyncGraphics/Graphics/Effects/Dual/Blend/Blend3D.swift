//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal

extension Graphic3D {
    
    private struct Blend3DUniforms {
        let blendingMode: Int32
        let placement: Int32
    }
    
    public func blended(with graphic: Graphic3D,
                        blendingMode: BlendingMode,
                        placement: Placement = .fit) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Blend",
            shader: .name("blend3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: Blend3DUniforms(
                blendingMode: Int32(blendingMode.index),
                placement: Int32(placement.index)
            )
        )
    }
}
