//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Average3DUniforms {
        let axis: UInt32
    }
    
    public func average(axis: Axis = .z) async throws -> Graphic {
        
        let resolution: CGSize = CGSize(
            width: axis == .x ? resolution.depth : resolution.width,
            height: axis == .y ? resolution.depth : resolution.height)
        
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
