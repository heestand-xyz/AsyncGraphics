//
//  Created by Anton Heestand on 2022-04-03.
//

import Metal
import SwiftUI
import CoreGraphicsExtensions

extension Graphic {
    
    private struct BlendUniforms {
        let blendingMode: Int32
        let placement: Int32
        let translation: PointUniform
        let rotation: Float
        let scale: Float
        let size: SizeUniform
        let horizontalAlignment: Int32
        let verticalAlignment: Int32
    }
    
    @EnumMacro
    public enum Alignment: String, GraphicEnum {
        
        case topLeading
        case top
        case topTrailing
        
        case leading
        case center
        case trailing
        
        case bottomLeading
        case bottom
        case bottomTrailing
        
        var horizontalIndex: Int32 {
            switch self {
            case .leading, .topLeading, .bottomLeading:
                return -1
            case .center, .top, .bottom:
                return 0
            case .trailing, .topTrailing, .bottomTrailing:
                return 1
            }
        }
        
        var verticalIndex: Int32 {
            switch self {
            case .top, .topLeading, .topTrailing:
                return -1
            case .center, .leading, .trailing:
                return 0
            case .bottom, .bottomLeading, .bottomTrailing:
                return 1
            }
        }
    }
    
    public mutating func blend(
        with graphic: Graphic,
        blendingMode: BlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        options: EffectOptions = []
    ) async throws {
        
        self = try await blended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            options: options.union(.replace)
        )
    }
    
    public func blended(
        with graphic: Graphic,
        blendingMode: BlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blend",
            shader: .name("blend"),
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                blendingMode: Int32(blendingMode.rawIndex),
                placement: Int32(placement.index),
                translation: .zero,
                rotation: 0.0,
                scale: 1.0,
                size: .one,
                horizontalAlignment: alignment.horizontalIndex,
                verticalAlignment: alignment.verticalIndex
            ),
            options: Renderer.Options(
                addressMode: options.addressMode, 
                filter: options.filter,
                targetSourceTexture: options.contains(.replace)
            )
        )
    }
    
    public mutating func transformBlend(
        with graphic: Graphic,
        blendingMode: BlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        size: CGSize? = nil,
        options: EffectOptions = []
    ) async throws {
        self = try await transformBlended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            translation: translation,
            rotation: rotation,
            scale: scale,
            size: size,
            options: options.union(.replace)
        )
    }
    
    public func transformBlended(
        with graphic: Graphic,
        blendingMode: BlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        size: CGSize? = nil,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        let relativeTranslation: CGPoint = translation / resolution.height
        let relativeSize: CGSize = (size ?? resolution) / resolution

        return try await Renderer.render(
            name: "Blend with Transform",
            shader: .name("blend"),
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                blendingMode: Int32(blendingMode.rawIndex),
                placement: Int32(placement.index),
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: relativeSize.uniform,
                horizontalAlignment: alignment.horizontalIndex,
                verticalAlignment: alignment.verticalIndex
            ),
            options: options.spatialRenderOptions
        )
    }
}

extension Graphic {
    
    public static func + (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(with: rhs, blendingMode: .add)
    }
    
    public static func - (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(with: rhs, blendingMode: .subtract)
    }
    
    public static func * (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(with: rhs, blendingMode: .multiply)
    }
    
    public static func / (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(with: rhs, blendingMode: .divide)
    }
}
