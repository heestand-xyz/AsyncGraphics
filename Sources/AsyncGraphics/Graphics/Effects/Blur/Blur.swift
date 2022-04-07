//
//  Created by Anton Heestand on 2022-04-07.
//

import Metal

public extension Graphic {
    
    private struct BlurUniforms {
        let type: Int
        let radius: Float
        let count: Int
        let angle: Float
        let position: PointUniform
    }
    
    func blurred() async throws -> Graphic {
        
        try await Renderer.render(
            shaderName: "blur",
            graphics: [self],
            uniforms: BlurUniforms(
                type: 0,
                radius: 0.5,
                count: 100,
                angle: 0.0,
                position: PointUniform(x: 0.0, y: 0.0)
            )
        )
    }
}

