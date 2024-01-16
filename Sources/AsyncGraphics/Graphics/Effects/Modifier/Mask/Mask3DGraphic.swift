import SwiftUI
import Spatial
import CoreGraphics

extension CodableGraphic3D.Effect.Modifier {
    
    @GraphicMacro
    public final class Mask: ModifierEffectGraphic3DProtocol {
        
        public var includeAlpha: GraphicMetadata<Bool> = .init(value: .fixed(true))
        
        public func render(
            with graphic: Graphic3D,
            modifier modifierGraphic: Graphic3D,
            options: Graphic3D.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic3D {
            
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
