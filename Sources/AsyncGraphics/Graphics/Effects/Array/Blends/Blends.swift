//
//  Created by Anton Heestand on 2022-04-12.
//

public extension Array where Element == Graphic {
    
    private struct BlendsUniforms {
        let mode: Int
    }
    
    func blended(blendingMode: ArrayBlendingMode) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blends",
            shaderName: "blends",
            graphics: self,
            uniforms: BlendsUniforms(
                mode: blendingMode.index
            ),
            isMulti: true
        )
    }
}