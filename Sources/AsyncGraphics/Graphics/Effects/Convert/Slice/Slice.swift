//
//  Slice.swift
//  AsyncGraphics
//
//  Created by Anton Heestand with AI on 2026-05-10.
//

import CoreGraphics

extension Graphic3D {
    
    private struct Slice3DUniforms: Uniforms {
        let axis: UInt32
        let location: Float
    }
    
    public func slice(
        axis: Axis = .z,
        location: CGFloat,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let resolution = CGSize(
            width: axis == .x ? resolution.depth : resolution.width,
            height: axis == .y ? resolution.depth : resolution.height
        )
        
        return try await Renderer.render(
            name: "Slice 3D",
            shader: .name("slice3d"),
            graphics: [
                self
            ],
            uniforms: Slice3DUniforms(
                axis: axis.index,
                location: Float(location)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: options.spatialRenderOptions
        )
    }
}
