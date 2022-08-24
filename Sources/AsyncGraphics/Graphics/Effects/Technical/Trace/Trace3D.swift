//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Trace3DUniforms {
        let alphaThreshold: Float
        let axis: Int
    }
    
    public func trace(axis: Axis = .z, alphaThreshold: CGFloat = 0.5) async throws -> Graphic {
        
        let resolution: CGSize = CGSize(width: axis == .x ? CGFloat(resolution.z) : CGFloat(resolution.x),
                                        height: axis == .y ? CGFloat(resolution.z) : CGFloat(resolution.y))
        
        return try await Renderer.render(
            name: "Trace",
            shader: .name("trace"),
            graphics: [bits(._8)],
            uniforms: Trace3DUniforms(
                alphaThreshold: Float(alphaThreshold),
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
