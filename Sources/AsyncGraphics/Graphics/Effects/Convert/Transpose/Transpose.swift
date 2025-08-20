//
//  Created by Anton Heestand on 2022-04-27.
//

import CoreGraphics

extension Graphic {
    
    private struct TransposeUniforms: Uniforms {
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
    
    public func mirroredHorizontally(
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await transpose(
            flip: .x,
            flop: .none,
            options: options
        )
    }
    
    public func mirroredVertically(
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await transpose(
            flip: .y,
            flop: .none,
            options: options
        )
    }
    
    public func rotatedLeft(
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await transpose(
            flip: .none,
            flop: .left,
            options: options
        )
    }
    
    public func rotatedRight(
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await transpose(
            flip: .none,
            flop: .right,
            options: options
        )
    }
    
    private func transpose(
        flip: Flip,
        flop: Flop,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
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
