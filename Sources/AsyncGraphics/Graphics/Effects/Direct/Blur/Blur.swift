//
//  Created by Anton Heestand on 2022-04-07.
//

import Metal
import CoreGraphics

extension Graphic {
    
    private struct BlurUniforms {
        let type: Int32
        let radius: Float
        let count: Int32
        let angle: Float
        let position: PointUniform
    }
    
    public func blurred(radius: CGFloat) async throws -> Graphic {
        
        let relativeRadius = radius / size.height
        
        return try await Renderer.render(
            name: "Blur",
            shaderName: "blur",
            graphics: [self],
            uniforms: BlurUniforms(
                type: 1,
                radius: Float(relativeRadius),
                count: 100,
                angle: 0.0,
                position: PointUniform(x: 0.0, y: 0.0)
            )
        )
    }
}

