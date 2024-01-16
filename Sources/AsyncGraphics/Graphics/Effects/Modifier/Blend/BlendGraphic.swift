import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class Blend: ModifierEffectGraphicProtocol {
        
        public var blendingMode: GraphicEnumMetadata<GraphicBlendMode> = .init(value: .add)
        
        public var placement: GraphicEnumMetadata<Placement> = .init(value: .fill)

        public var alignment: GraphicEnumMetadata<Graphic.Alignment> = .init(value: .center)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
                       
            try await graphic.blended(
                with: modifierGraphic,
                blendingMode: blendingMode.value,
                placement: placement.value,
                alignment: alignment.value,
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
