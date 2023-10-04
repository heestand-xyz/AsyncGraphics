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
    
    public enum Alignment {
        
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
    
    @available(*, deprecated, renamed: "blended(with:blendingMode:placement:alignment:options:)")
    public func blended(
        blendingMode: AGBlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
        
        try await blended(
            with: graphic(),
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            options: options,
            targetSourceTexture: false
        )
    }
    
    public func blended(
        with graphic: Graphic,
        blendingMode: AGBlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        options: EffectOptions = []
    ) async throws -> Graphic {
        
        try await blended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            options: options,
            targetSourceTexture: false
        )
    }
    
    public mutating func blend(
        with graphic: Graphic,
        blendingMode: AGBlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        options: EffectOptions = []
    ) async throws {
        
        self = try await blended(
            with: graphic,
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            options: options,
            targetSourceTexture: true
        )
    }
    
    private func blended(
        with graphic: Graphic,
        blendingMode: AGBlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        options: EffectOptions = [],
        targetSourceTexture: Bool
    ) async throws -> Graphic {
        
        try await Renderer.render(
            name: "Blend",
            shader: .name("blend"),
            graphics: [
                self,
                graphic
            ],
            uniforms: BlendUniforms(
                blendingMode: Int32(blendingMode.index),
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
                targetSourceTexture: targetSourceTexture
            )
        )
    }
    
//    @available(*, deprecated, renamed: "transformBlended(blendingMode:placement:translation:rotation:scale:size:options:graphic:)")
    public func transformBlended(
        with graphic: Graphic,
        blendingMode: AGBlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        size: CGSize? = nil,
        options: EffectOptions = []
    ) async throws -> Graphic {
        try await transformBlended(
            blendingMode: blendingMode,
            placement: placement,
            alignment: alignment,
            translation: translation,
            rotation: rotation,
            scale: scale,
            size: size,
            options: options
        ) {
            graphic
        }
    }
    
    public func transformBlended(
        blendingMode: AGBlendMode,
        placement: Placement = .fit,
        alignment: Alignment = .center,
        translation: CGPoint = .zero,
        rotation: Angle = .zero,
        scale: CGFloat = 1.0,
        size: CGSize? = nil,
        options: EffectOptions = [],
        graphic: () async throws -> Graphic
    ) async throws -> Graphic {
       
        let relativeTranslation: CGPoint = translation / resolution.height
        let relativeSize: CGSize = (size ?? resolution) / resolution

        return try await Renderer.render(
            name: "Blend with Transform",
            shader: .name("blend"),
            graphics: [
                self,
                graphic()
            ],
            uniforms: BlendUniforms(
                blendingMode: Int32(blendingMode.index),
                placement: Int32(placement.index),
                translation: relativeTranslation.uniform,
                rotation: rotation.uniform,
                scale: Float(scale),
                size: relativeSize.uniform,
                horizontalAlignment: alignment.horizontalIndex,
                verticalAlignment: alignment.verticalIndex
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
    
//    @available(*, deprecated, renamed: "mask(placement:options:foreground:background:mask:)")
    public static func mask(
        foreground foregroundGraphic: Graphic,
        background backgroundGraphic: Graphic,
        mask maskGraphic: Graphic,
        placement: Placement = .fit,
        options: EffectOptions = []
    ) async throws -> Graphic {
        try await mask(placement: placement, options: options) {
            foregroundGraphic
        } background: {
            backgroundGraphic
        } mask: {
            maskGraphic
        }
    }
    
    public static func mask(
        placement: Placement = .fit,
        options: EffectOptions = [],
        foreground foregroundGraphic: () async throws -> Graphic,
        background backgroundGraphic: () async throws -> Graphic,
        mask maskGraphic: () async throws -> Graphic
    ) async throws -> Graphic {
        let alphaGraphic = try await maskGraphic().luminanceToAlpha()
        let graphic = try await alphaGraphic.blended(with: foregroundGraphic(), blendingMode: .multiply, placement: placement)
        return try await backgroundGraphic().blended(with: graphic, blendingMode: .over, placement: placement)
    }
}

extension Graphic {
    
    public static func + (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(blendingMode: .add) { rhs }
    }
    
    public static func - (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(blendingMode: .subtract) { rhs }
    }
    
    public static func * (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(blendingMode: .multiply) { rhs }
    }
    
    public static func / (lhs: Graphic, rhs: Graphic) async throws -> Graphic {
        try await lhs.blended(blendingMode: .divide) { rhs }
    }
}
