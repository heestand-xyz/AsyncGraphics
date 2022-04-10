//
//  Created by Anton Heestand on 2022-04-03.
//

import Metal

public extension Graphic {
    
    private struct BlendUniforms {
        let blendingMode: Int
        let placement: Int
    }
    
    func blended(with graphic: Graphic,
                 blendingMode: BlendingMode,
                 placement: Placement = .fit) async throws -> Graphic {
        
        try await Renderer.render(
            shaderName: "blend",
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                blendingMode: blendingMode.index,
                placement: placement.index
            )
        )
    }
}
