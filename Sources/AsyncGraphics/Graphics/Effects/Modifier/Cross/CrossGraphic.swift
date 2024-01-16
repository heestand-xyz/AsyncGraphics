import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class Cross: ModifierEffectGraphicProtocol {
        
        public var fraction: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5))
        
        public var placement: GraphicEnumMetadata<Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
                       
            try await graphic.cross(
                with: modifierGraphic,
                fraction: fraction.value.eval(at: graphic.resolution),
                placement: placement.value,
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
