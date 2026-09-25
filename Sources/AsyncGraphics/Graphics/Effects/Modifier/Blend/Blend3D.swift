//
//  Created by Anton Heestand on 2022-04-13.
//

import Metal
import Spatial
import SpatialExtensions

extension Graphic3D {
    
    private struct Blend3DUniforms: Uniforms {
        let blendingMode: Int32
        let placement: Int32
        let alignment: VectorUniform
    }
    
    mutating public func blend(
        with graphic: Graphic3D,
        blendingMode: Graphic.BlendMode,
        placement: Graphic.Placement = .fit,
        alignment: Alignment3D = .center,
        options: EffectOptions = []
    ) async throws {
        self = try await blended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            targetSourceTexture: true,
            options: options
        )
    }
    
    public func blended(
        with graphic: Graphic3D,
        blendingMode: Graphic.BlendMode,
        placement: Graphic.Placement = .fit,
        alignment: Alignment3D = .center,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        
        try await blended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            targetSourceTexture: false,
            options: options
        )
    }
    
    private func blended(
        with graphic: Graphic3D,
        blendingMode: Graphic.BlendMode,
        placement: Graphic.Placement,
        alignment: Alignment3D,
        targetSourceTexture: Bool,
        options: EffectOptions = []
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
                placement: Int32(placement.index),
                alignment: Point3D(x: Double(alignment.x.vector),
                                   y: Double(alignment.y.vector),
                                   z: Double(alignment.z.vector)).uniform
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                targetSourceTexture: targetSourceTexture
            )
        )
    }
}

// MARK: - Operators

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
