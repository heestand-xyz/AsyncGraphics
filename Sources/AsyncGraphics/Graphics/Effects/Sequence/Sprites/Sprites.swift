//
//  Created by Anton Heestand on 2022-04-12.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension Graphic {
    
    /// Hardcoded. Also defined in Metal file.
    public static let maximumSpriteCount: Int = 1024
    
    private struct SpritesUniforms: Uniforms {
        let resolution: SizeUniform
        let backgroundColor: ColorUniform
    }
    
    public struct Sprite: Sendable {
        let position: CGPoint
        let size: CGSize?
        let scale: CGFloat
        let rotation: Angle
        let tint: PixelColor
        let blendingMode: BlendMode
        let placement: Placement
        let alignment: Alignment
        public init(
            position: CGPoint,
            size: CGSize? = nil,
            scale: CGFloat = 1.0,
            rotation: Angle = .zero,
            tint: PixelColor = .white,
            blendingMode: BlendMode = .over,
            placement: Placement = .fit,
            alignment: Alignment = .center
        ) {
            self.position = position
            self.size = size
            self.scale = scale
            self.rotation = rotation
            self.tint = tint
            self.blendingMode = blendingMode
            self.placement = placement
            self.alignment = alignment
        }
        static let empty = Sprite(position: .zero)
        fileprivate func uniforms(
            resolution: CGSize,
            graphicResolution: CGSize
        ) -> SpriteUniforms {
            SpriteUniforms(
                blendingMode: Int32(blendingMode.rawIndex),
                placement: Int32(placement.index),
                tint: tint.uniform,
                position: (position / resolution).uniform,
                size: ((size ?? graphicResolution) / resolution).uniform,
                scale: Float(scale),
                rotation: Float(rotation.degrees / 360),
                horizontalAlignment: alignment.horizontalIndex,
                verticalAlignment: alignment.verticalIndex
            )
        }
    }
    
    fileprivate struct SpriteUniforms: Uniforms {
        let blendingMode: Int32
        let placement: Int32
        let tint: ColorUniform
        let position: PointUniform
        let size: SizeUniform
        let scale: Float
        let rotation: Float
        let horizontalAlignment: Int32
        let verticalAlignment: Int32
    }
    
    enum SpritesError: LocalizedError {
        case mixedSpriteGraphicResolutions
        case maximumSpriteCountExceeded
        var localizedDescription: String {
            switch self {
            case .mixedSpriteGraphicResolutions:
                "Mixed sprite graphic resolutions. All graphics need the same resolution."
            case .maximumSpriteCountExceeded:
                "Maximum sprite count of \(Graphic.maximumSpriteCount) exceeded."
            }
        }
    }
    
    public static func sprites(
        with graphics: [Graphic],
        sprites: [Sprite],
        backgroundColor: PixelColor = .clear,
        resolution: CGSize,
        contentOptions: ContentOptions = [],
        effectOptions: EffectOptions = []
    ) async throws -> Graphic {
        
        guard !graphics.isEmpty else {
            return try await .color(backgroundColor, resolution: resolution)
        }
        let graphicResolution: CGSize = graphics.first!.resolution
        if graphics.count > 1 {
            guard graphics.dropFirst().allSatisfy({ $0.resolution == graphicResolution }) else {
                throw SpritesError.mixedSpriteGraphicResolutions
            }
        }
        
        guard graphics.count <= Self.maximumSpriteCount,
              sprites.count <= Self.maximumSpriteCount else {
            throw SpritesError.maximumSpriteCountExceeded
        }
        
        return try await Renderer.render(
            name: "Sprites",
            shader: .name("sprites"),
            graphics: graphics,
            uniforms: SpritesUniforms(
                resolution: resolution.uniform,
                backgroundColor: backgroundColor.uniform
            ),
            arrayUniforms: sprites.map({ sprite in
                sprite.uniforms(resolution: resolution, graphicResolution: graphicResolution)
            }),
            emptyArrayUniform: Sprite.empty.uniforms(resolution: .one, graphicResolution: .one),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: contentOptions.colorSpace,
                bits: contentOptions.bits
            ),
            options: Renderer.Options(
                isArray: true,
                addressMode: effectOptions.addressMode,
                filter: effectOptions.filter,
                overrideUniformArrayMaxLimit: Self.maximumSpriteCount
            )
        )
    }
}
