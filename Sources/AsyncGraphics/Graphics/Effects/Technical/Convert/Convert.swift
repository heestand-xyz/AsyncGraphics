//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics

extension Graphic {
    
    private struct ConvertUniforms {
        let conversion: UInt32
    }
    
    public enum Conversion: String, Codable, Identifiable, CaseIterable {
        case domeToEqui
        case equiToDome
        case cubeToEqui
        case squareToCircle
        case circleToSquare
        public var id: String { rawValue }
        var index: UInt32 {
            switch self {
            case .domeToEqui: return 0
            case .equiToDome: return 1
            case .cubeToEqui: return 2
            case .squareToCircle: return 4
            case .circleToSquare: return 5
            }
        }
    }
    
    public func converted(_ conversion: Conversion,
                          options: EffectOptions = []) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Convert",
            shader: .name("convert"),
            graphics: [self],
            uniforms: ConvertUniforms(
                conversion: conversion.index
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
