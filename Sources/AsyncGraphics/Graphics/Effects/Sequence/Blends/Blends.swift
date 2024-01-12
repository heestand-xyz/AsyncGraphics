//
//  Created by Anton Heestand on 2022-04-12.
//

extension Graphic {
    
    private struct BlendsUniforms {
        let mode: Int
    }
    
    public static func add(with graphics: [Graphic]) async throws -> Graphic {
        
        try await blend(with: graphics, blendingMode: .add)
    }
    
    public static func average(with graphics: [Graphic]) async throws -> Graphic {
        
        try await blend(with: graphics, blendingMode: .average)
    }
    
    public static func blend(with graphics: [Graphic],
                             blendingMode: GraphicArrayBlendMode) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blends",
            shader: .name("blends"),
            graphics: graphics,
            uniforms: BlendsUniforms(
                mode: blendingMode.rawIndex
            ),
            options: Renderer.Options(
                isArray: true
            )
        )
    }
}


extension Array where Element == Graphic {
    
    public func add() async throws -> Graphic {
        
        try await Graphic.blend(with: self, blendingMode: .add)
    }
    
    public func average() async throws -> Graphic {
        
        try await Graphic.blend(with: self, blendingMode: .average)
    }
    
    public func blended(blendingMode: GraphicArrayBlendMode) async throws -> Graphic {
        
        try await Graphic.blend(with: self, blendingMode: blendingMode)
    }
}
