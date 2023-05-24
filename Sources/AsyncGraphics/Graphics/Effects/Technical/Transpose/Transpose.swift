//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics

extension Graphic {
    
    private struct TransposeUniforms {
        let flip: UInt32
        let flop: UInt32
    }
    
    private enum Flip: Int {
        case none
        case x
        case y
        case xy
    }
    
    private enum Flop: Int {
        case none
        case left
        case right
    }
    
    public func mirroredHorizontally() async throws -> Graphic {
        
        try await transpose(flip: .x, flop: .none)
    }
    
    public func mirroredVertically() async throws -> Graphic {
        
        try await transpose(flip: .y, flop: .none)
    }
    
    public func rotatedLeft() async throws -> Graphic {
        
        try await transpose(flip: .none, flop: .left)
    }
    
    public func rotatedRight() async throws -> Graphic {
        
        try await transpose(flip: .none, flop: .right)
    }
    
    private func transpose(flip: Flip, flop: Flop) async throws -> Graphic {
        
        let resolution: CGSize = flop != .none ? CGSize(width: resolution.height, height: resolution.width) : resolution
        
        return try await Renderer.render(
            name: "Transpose",
            shader: .name("transpose"),
            graphics: [self],
            uniforms: TransposeUniforms(
                flip: UInt32(flip.rawValue),
                flop: UInt32(flop.rawValue)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            )
        )
    }
}
