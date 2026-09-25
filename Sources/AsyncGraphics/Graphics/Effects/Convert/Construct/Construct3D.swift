//
//  Construct3D.swift
//
//
//  Created by Anton Heestand on 2023-11-16.
//

import Foundation
import Spatial

extension Graphic3D {
    
    private struct Construct3DUniforms: Uniforms {
        let axis: UInt32
    }
    
    enum ConstructError: LocalizedError {
        
        case noGraphics

        var errorDescription: String? {
            switch self {
            case .noGraphics:
                return "Async Graphics - Construct - No Graphics"
            }
        }
    }
    
    public static func construct(
        graphics: [Graphic],
        axis: Axis = .z,
        options: EffectOptions = []
    ) async throws -> Graphic3D {
        if graphics.isEmpty {
            throw ConstructError.noGraphics
        }
        return try await Renderer.render(
            name: "Construct 3D",
            shader: .name("construct3d"),
            graphics: graphics,
            uniforms: Construct3DUniforms(axis: axis.index),
            metadata: Renderer.Metadata(
                resolution: Size3D(
                    width: axis == .x ? Double(graphics.count) : graphics.first!.width,
                    height: axis == .y ? Double(graphics.count) : graphics.first!.height,
                    depth: axis == .x ? graphics.first!.width : axis == .y ? graphics.first!.height : Double(graphics.count)
                ),
                colorSpace: graphics.first!.colorSpace,
                bits: graphics.first!.bits
            ),
            options: Renderer.Options(
                isArray: true,
                targetSourceTexture: options.contains(.replace)
            )
        )
    }
}
