import CoreGraphics
import PixelColor

extension Graphic {
    
    private struct PaddingUniforms {
        let onLeading: Bool
        let onTrailing: Bool
        let onTop: Bool
        let onBottom: Bool
        let padding: Float
    }
    
    public func padding(on edgeInsets: EdgeInsets = .all,
                        _ length: CGFloat,
                        options: EffectOptions = []) async throws -> Graphic {
        
        var width: CGFloat = resolution.width
        var height: CGFloat = resolution.height
        if edgeInsets.onLeading {
            width += length
        }
        if edgeInsets.onTrailing {
            width += length
        }
        if edgeInsets.onTop {
            height += length
        }
        if edgeInsets.onBottom {
            height += length
        }
        let resolution = CGSize(width: width, height: height)
        
        return try await Renderer.render(
            name: "Padding",
            shader: .name("padding"),
            graphics: [self],
            uniforms: PaddingUniforms(
                onLeading: edgeInsets.onLeading,
                onTrailing: edgeInsets.onTrailing,
                onTop: edgeInsets.onTop,
                onBottom: edgeInsets.onBottom,
                padding: Float(length)
            ),
            metadata: Renderer.Metadata(
                resolution: resolution,
                colorSpace: colorSpace,
                bits: bits
            ),
            options: Renderer.Options(
                addressMode: options.addressMode,
                filter: options.filter
            )
        )
    }
}
