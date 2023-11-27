//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Add3DUniforms {
        let axis: UInt32
    }
    
    public func add(axis: Axis = .z) async throws -> Graphic {
        
        let resolution: CGSize = CGSize(width: axis == .x ? CGFloat(resolution.z) : CGFloat(resolution.x),
                                        height: axis == .y ? CGFloat(resolution.z) : CGFloat(resolution.y))
        
        return try await Renderer.render(
            name: "Add 3D",
            shader: .name("add3d"),
            graphics: [bits(._8)],
            uniforms: Add3DUniforms(
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
