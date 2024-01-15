import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class Mask: ModifierEffectGraphicProtocol {
        
        public var includeAlpha: GraphicMetadata<Bool> = .init(value: .fixed(true))
        
        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
           
            let includeAlpha: Bool = includeAlpha.value.eval(at: graphic.resolution)
            
            return try await graphic.blended(
                with: modifierGraphic,
                blendingMode: includeAlpha ? .multiply : .multiplyWithoutAlpha
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
