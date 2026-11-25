//
//  Created by Anton Heestand on 2022-04-12.
//

import SwiftUI
import CoreGraphics
import CoreGraphicsExtensions
import Metal
import PixelColor

extension Graphic {
    
    /// Maximum number of input graphics or sprites in one render.
    public static let maximumSpriteCount: Int = 1024
    
    private struct SpritesUniforms: Uniforms {
        let backgroundColor: ColorUniform
        let count: UInt32
        let samplingPadding: SizeUniform
    }
    
    public struct Sprite: Sendable {
        let position: CGPoint
        let size: CGSize?
        let scale: CGSize
        let rotation: Angle
        let tint: PixelColor
        let blendingMode: BlendMode
        let placement: Placement
        let alignment: Alignment
        public init(
            position: CGPoint,
            size: CGSize? = nil,
            scale: CGSize = .one,
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
        fileprivate func uniforms(
            resolution: CGSize,
            graphicResolution: CGSize,
            outputPixels: SizeUniform,
            texture: SpriteTextureUniforms
        ) -> SpriteUniforms? {
            let outputAspect: Float = Float(resolution.width / resolution.height)
            let textureAspect: Float = Float(graphicResolution.width / graphicResolution.height)
            let size: SizeUniform = (((size ?? graphicResolution) / resolution) * scale).uniform
            let spriteScale = SIMD2<Float>(size.width * outputAspect / textureAspect, size.height)
            guard spriteScale.x > 0, spriteScale.y > 0 else { return nil }

            // Placement uses the allocated pixel grid. Position and sprite scale are
            // normalized against the originally requested resolution.
            let aspectRatio: Float = (outputPixels.width / outputPixels.height) / textureAspect
            let placementScale: SIMD2<Float>
            let translationScale: SIMD2<Float>
            switch placement {
            case .stretch:
                placementScale = SIMD2(repeating: 1)
                translationScale = SIMD2(1 / aspectRatio, 1)
            case .fit:
                placementScale = SIMD2(max(1, aspectRatio), max(1, 1 / aspectRatio))
                translationScale = SIMD2(repeating: placementScale.y)
            case .fill:
                placementScale = SIMD2(min(1, aspectRatio), min(1, 1 / aspectRatio))
                translationScale = SIMD2(repeating: placementScale.y)
            case .fixed:
                placementScale = SIMD2(
                    outputPixels.width / Float(graphicResolution.width),
                    outputPixels.height / Float(graphicResolution.height)
                )
                translationScale = SIMD2(repeating: placementScale.y)
            }

            // Combine placement and rotation into the two axes of the output-to-texture transform.
            let turns: Float = Float(rotation.degrees / 360)
            let radians: Float = turns * .pi * 2
            let cosine: Float = cos(radians)
            let sine: Float = sin(radians)
            let xAxis = SIMD2<Float>(cosine / textureAspect, -sine) / spriteScale
            let yAxis = SIMD2<Float>(sine / textureAspect, cosine) / spriteScale
            let placementAxes = SIMD2<Float>(placementScale.x * textureAspect, placementScale.y)
            let offset = SIMD2<Float>(
                (Float(position.x / resolution.width) - 0.5) * outputAspect,
                Float(position.y / resolution.height) - 0.5
            ) * translationScale
            let alignmentIndices = SIMD2<Float>(Float(alignment.horizontalIndex), Float(alignment.verticalIndex))
            let alignmentOffset: SIMD2<Float> = (1 - placementScale) * 0.5 * alignmentIndices
            // Apply alignment to the center in output space, before dividing by small sprite scales.
            let rotatedAlignmentOffset =
                alignmentOffset.x * textureAspect * SIMD2(cosine, sine) +
                alignmentOffset.y * SIMD2(-sine, cosine)
            let center: SIMD2<Float> = (offset - rotatedAlignmentOffset) / placementAxes
            let uvXAxis: SIMD2<Float> = xAxis * placementAxes.x
            let uvYAxis: SIMD2<Float> = yAxis * placementAxes.y

            let transparentSampleIsIdentity: Bool = switch blendingMode {
            case .over, .overWithAlpha, .add, .addWithAlpha: true
            default: false
            }
            return SpriteUniforms(
                blendingMode: Int32(blendingMode.rawIndex),
                texture: texture,
                transparentSampleIsIdentity: transparentSampleIsIdentity ? 1 : 0,
                tint: tint.uniform,
                center: PointUniform(x: center.x, y: center.y),
                xAxis: PointUniform(x: uvXAxis.x, y: uvXAxis.y),
                yAxis: PointUniform(x: uvYAxis.x, y: uvYAxis.y)
            )
        }
    }
    
    fileprivate struct SpriteUniforms: Uniforms {
        let blendingMode: Int32
        let texture: SpriteTextureUniforms
        let transparentSampleIsIdentity: UInt32
        let tint: ColorUniform
        let center: PointUniform
        let xAxis: PointUniform
        let yAxis: PointUniform
    }
    
    fileprivate struct SpriteTextureUniforms: Uniforms {
        let index: UInt32
        let swizzle: SIMD4<UInt8>
        let hasTransparentBlackBorder: UInt32

        init(texture: MTLTexture, index: Int, clampToZero: Bool) {
            self.index = UInt32(index)
            let channels: MTLTextureSwizzleChannels = texture.swizzle
            swizzle = SIMD4(channels.red.rawValue, channels.green.rawValue, channels.blue.rawValue, channels.alpha.rawValue)
            switch texture.pixelFormat {
            case .rgba8Unorm, .rgba8Unorm_srgb, .bgra8Unorm, .bgra8Unorm_srgb, .rgba16Unorm, .rgba16Float, .rgba32Float:
                let preservesZero: Bool = channels.red != .one && channels.green != .one && channels.blue != .one && channels.alpha != .one
                hasTransparentBlackBorder = clampToZero && preservesZero ? 1 : 0
            default:
                hasTransparentBlackBorder = 0
            }
        }
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
        
        guard let firstGraphic = graphics.first else {
            return try await .color(backgroundColor, resolution: resolution, options: contentOptions.union(.pureAlpha))
        }
        let graphicResolution: CGSize = firstGraphic.resolution
        if graphics.count > 1 {
            guard graphics.dropFirst().allSatisfy({ $0.resolution == graphicResolution }) else {
                throw SpritesError.mixedSpriteGraphicResolutions
            }
        }
        
        guard graphics.count <= Self.maximumSpriteCount,
              sprites.count <= Self.maximumSpriteCount else {
            throw SpritesError.maximumSpriteCountExceeded
        }

        var spriteUniforms: [SpriteUniforms] = []
        if !sprites.isEmpty {
            let clampToZero: Bool = effectOptions.addressMode == .clampToZero
            let textures: [SpriteTextureUniforms] = graphics.enumerated().map { index, graphic in
                SpriteTextureUniforms(texture: graphic.texture, index: index, clampToZero: clampToZero)
            }
            let outputPixels: SizeUniform = resolution.pixelDimensionsUniform
            let count: Int = max(graphics.count, sprites.count)
            spriteUniforms.reserveCapacity(count)
            // Keep each original texture assignment when removing zero-scale sprites.
            for index in 0..<count {
                if let uniforms = sprites[index % sprites.count].uniforms(
                    resolution: resolution,
                    graphicResolution: graphicResolution,
                    outputPixels: outputPixels,
                    texture: textures[index % textures.count]
                ) {
                    spriteUniforms.append(uniforms)
                }
            }
        }
        guard !spriteUniforms.isEmpty else {
            return try await .color(backgroundColor, resolution: resolution, options: contentOptions.union(.pureAlpha))
        }

        let texture: MTLTexture = firstGraphic.texture
        let usage: MTLTextureUsage = texture.usage
        // An empty usage mask is Metal's unrestricted .unknown usage.
        let useDirectTexture: Bool = graphics.count == 1 && (usage.isEmpty || usage.contains(.shaderRead))
        return try await Renderer.render(
            name: "Sprites",
            shader: .name(useDirectTexture ? "spritesSingleTexture" : "sprites"),
            graphics: graphics,
            uniforms: SpritesUniforms(
                backgroundColor: backgroundColor.uniform,
                count: UInt32(spriteUniforms.count),
                // Leave room for linear filtering at the texture border.
                samplingPadding: SizeUniform(
                    width: 1 / Float(graphicResolution.width),
                    height: 1 / Float(graphicResolution.height)
                )
            ),
            arrayUniforms: spriteUniforms,
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: contentOptions.colorSpace,
                bits: contentOptions.bits
            ),
            options: Renderer.Options(
                isArray: !useDirectTexture,
                addressMode: effectOptions.addressMode,
                filter: effectOptions.filter
            )
        )
    }
}
