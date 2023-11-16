//
//  Construct3D.swift
//
//
//  Created by Anton Heestand on 2023-11-16.
//

import Foundation

extension Graphic3D {
    
    enum ConstructError: LocalizedError {
        
        case noGraphics

        var errorDescription: String? {
            switch self {
            case .noGraphics:
                return "Async Graphics - Construct - No Graphics"
            }
        }
    }
    
    public static func construct(graphics: [Graphic]) async throws -> Graphic3D {
        if graphics.isEmpty {
            throw ConstructError.noGraphics
        }
        return try await Renderer.render(
            name: "Construct",
            shader: .name("construct3d"),
            graphics: graphics,
            metadata: Renderer.Metadata(
                resolution: SIMD3<Int>(
                    Int(graphics.first!.width),
                    Int(graphics.first!.height),
                    graphics.count
                ),
                colorSpace: graphics.first!.colorSpace,
                bits: graphics.first!.bits
            )
        )
    }
}
