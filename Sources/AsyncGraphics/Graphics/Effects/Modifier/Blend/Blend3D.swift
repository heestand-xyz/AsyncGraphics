//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal

extension Graphic3D {
    
    private struct Blend3DUniforms {
        let blendingMode: Int32
        let placement: Int32
    }
    
    mutating public func blend(with graphic: Graphic3D,
                               blendingMode: AGBlendMode,
                               placement: Placement = .fit) async throws {
        self = try await blended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            targetSourceTexture: true
        )
    }
    
    public func blended(with graphic: Graphic3D,
                        blendingMode: AGBlendMode,
                        placement: Placement = .fit) async throws -> Graphic3D {
        
        try await blended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            targetSourceTexture: false
        )
    }
    
    private func blended(
        with graphic: Graphic3D,
        blendingMode: AGBlendMode,
        placement: Placement,
        targetSourceTexture: Bool
    ) async throws -> Graphic3D {
        
        try await Renderer.render(
            name: "Blend 3D",
            shader: .name("blend3d"),
            graphics: [
                self,
                graphic
            ],
            uniforms: Blend3DUniforms(
                blendingMode: Int32(blendingMode.rawIndex),
                placement: Int32(placement.index)
            ),
            options: Renderer.Options(
                targetSourceTexture: targetSourceTexture
            )
        )
    }
}

extension Graphic3D {
    
    public static func + (lhs: Graphic3D, rhs: Graphic3D) async throws -> Graphic3D {
        try await lhs.blended(with: rhs, blendingMode: .add)
    }
    
    public static func - (lhs: Graphic3D, rhs: Graphic3D) async throws -> Graphic3D {
        try await lhs.blended(with: rhs, blendingMode: .subtract)
    }
    
    public static func * (lhs: Graphic3D, rhs: Graphic3D) async throws -> Graphic3D {
        try await lhs.blended(with: rhs, blendingMode: .multiply)
    }
    
    public static func / (lhs: Graphic3D, rhs: Graphic3D) async throws -> Graphic3D {
        try await lhs.blended(with: rhs, blendingMode: .divide)
    }
}