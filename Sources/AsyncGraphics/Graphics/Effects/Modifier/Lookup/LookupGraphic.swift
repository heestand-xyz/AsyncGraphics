import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class Lookup: ModifierEffectGraphicProtocol {
        
        public var sampleCoordinate: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5))
        
        public var axis: GraphicEnumMetadata<Graphic.LookupAxis> = .init(value: .vertical)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
           
            try await graphic.lookup(
                with: modifierGraphic,
                axis: axis.value,
                sampleCoordinate: sampleCoordinate.value.eval(at: graphic.resolution),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            }
        }
    }
}
