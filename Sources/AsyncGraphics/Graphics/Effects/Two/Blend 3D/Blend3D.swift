//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal

public extension Graphic3D {
    
    private struct Blend3DUniforms {
        let blendingMode: Int
        let placement: Int
    }
    
    func blended(with graphic: Graphic3D,
                 blendingMode: BlendingMode,
                 placement: Placement = .fit) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Blend",
            shaderName: "blend3d",
            graphics: [
                self,
                graphic
            ],
            uniforms: Blend3DUniforms(
                blendingMode: blendingMode.index,
                placement: placement.index
            )
        )
    }
}
