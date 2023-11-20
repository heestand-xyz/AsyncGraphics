//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Average3DUniforms {
        let axis: Int
    }
    
    public func average(axis: Axis = .z) async throws -> Graphic {
        
        let resolution: CGSize = CGSize(
            width: axis == .x ? CGFloat(resolution.z) : CGFloat(resolution.x),
            height: axis == .y ? CGFloat(resolution.z) : CGFloat(resolution.y))
        
        return try await Renderer.render(
            name: "Average",
            shader: .name("average"),
            graphics: [bits(._8)],
            uniforms: Average3DUniforms(
                axis: axis.index
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}
