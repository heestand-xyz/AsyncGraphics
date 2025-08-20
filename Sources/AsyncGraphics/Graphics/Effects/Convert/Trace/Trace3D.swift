//
//  Created by Anton Heestand on 2022-04-11.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Trace3DUniforms: Uniforms {
        let reversed: Bool
        let alphaThreshold: Float
        let axis: UInt32
    }
    
    public func trace(axis: Axis = .z, reversed: Bool = false, alphaThreshold: CGFloat = 0.5) async throws -> Graphic {
        
        let resolution: CGSize = CGSize(
            width: axis == .x ? resolution.depth : resolution.width,
            height: axis == .y ? resolution.depth : resolution.height)
        
        return try await Renderer.render(
            name: "Trace",
            shader: .name("trace"),
            graphics: [withBits(.bit8)],
            uniforms: Trace3DUniforms(
                reversed: reversed,
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
