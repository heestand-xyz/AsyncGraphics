//
//  Created by Anton Heestand on 2022-04-12.
//

extension Array where Element == Graphic {
    
    private struct BlendsUniforms {
        let mode: Int
    }
    
    public func blended(blendingMode: ArrayBlendingMode) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blends",
            shaderName: "blends",
            graphics: self,
            uniforms: BlendsUniforms(
                mode: blendingMode.index
            ),
            options: Renderer.Options(isMulti: true)
        )
    }
}
