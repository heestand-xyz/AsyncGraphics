import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class Displace: ModifierEffectGraphicProtocol {
        
        public var docs: String {
            "Displace the first graphic with the seconds graphics red (x) and green (y) colors."
        }
        
        public var offset: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            options: .spatial)
        
        public var origin: GraphicMetadata<PixelColor> = .init(value: .fixed(.rawGray))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)
        
        public var extendMode: GraphicEnumMetadata<Graphic.ExtendMode> = .init(
            value: .stretch,
            docs: "Pixels outside the main bounds will use the extend mode when sampled. This will mainly affect pixels on the edges."
        )
        
        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
           
            try await graphic.displaced(
                with: modifierGraphic,
                offset: offset.value.eval(at: graphic.resolution),
                origin: origin.value.eval(at: graphic.resolution),
                placement: placement.value,
                options: options.union(extendMode.value.options)
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
