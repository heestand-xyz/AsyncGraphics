import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class Saliency: ColorEffectGraphicProtocol {
        
        public var docs: String {
            "Detect attention or objectness of a graphic, as a monochrome heat map."
        }
        
        public var tags: [String] {
            ["Attention", "Objectness", "Heat Map"]
        }
        
        public var saliencyType: GraphicEnumMetadata<Graphic.SaliencyType> = .init(value: .attention)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            if #available(iOS 18.0, tvOS 18.0, macOS 15.0, visionOS 2.0, *) {
                try await graphic.saliency(of: saliencyType.value)
            } else {
                try await .color(.clear, resolution: graphic.resolution)
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case attention
            case objectness
        }

        public func edit(variant: Variant) {
            switch variant {
            case .attention:
                saliencyType = .init(value: .attention)
            case .objectness:
                saliencyType = .init(value: .objectness)
            }
        }
    }
}
