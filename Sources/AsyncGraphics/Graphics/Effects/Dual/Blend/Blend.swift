//
//  Created by Anton Heestand on 2022-04-03.
//

import Metal

public extension Graphic {
    
    private struct BlendUniforms {
        let blendingMode: Int32
        let placement: Int32
    }
    
    func blended(with graphic: Graphic,
                 blendingMode: BlendingMode,
                 placement: Placement = .fit) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blend",
            shaderName: "blend",
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                blendingMode: Int32(blendingMode.index),
                placement: Int32(placement.index)
            )
        )
    }
}
