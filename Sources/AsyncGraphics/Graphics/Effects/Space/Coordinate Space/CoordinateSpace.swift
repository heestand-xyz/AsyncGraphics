//
//  Created by Anton Heestand on 2022-08-26.
//

import CoreGraphics

extension Graphic {
    
    private struct CoordinateSpaceUniforms {
        let conversion: UInt32
        let rotationX: Float
        let rotationY: Float
        let fraction: Float
    }
    
    public enum CoordinateSpaceConversion: String, Codable, Identifiable, CaseIterable {
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
    
    /// Coordinate Space
    /// - Parameters:
    ///   - conversion: The type of coordinate space conversion
    ///   - rotation: Only used for `.equiToDome`
    ///   - fraction: The amount of conversion, `0.0` is no conversion and `1.0` is full conversion.
    public func coordinateSpace(_ conversion: CoordinateSpaceConversion,
                                rotation: CGVector = .zero,
                                fraction: CGFloat = 1.0,
                                options: EffectOptions = []) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Coordinate Space",
            shader: .name("coordinateSpace"),
            graphics: [self],
            uniforms: CoordinateSpaceUniforms(
                conversion: conversion.index,
                rotationX: Float(rotation.dx),
                rotationY: Float(rotation.dy),
                fraction: Float(fraction)
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
