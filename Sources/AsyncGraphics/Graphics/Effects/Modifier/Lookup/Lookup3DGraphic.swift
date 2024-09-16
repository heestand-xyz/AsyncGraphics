import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Modifier {
    
    @GraphicMacro
    public final class Lookup: ModifierEffectGraphic3DProtocol {
        
        public var docs: String {
            "Lookup colors in the second graphic based on the first graphics luminance."
        }
        
        public var sampleCoordinate: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5))
        
        public var axis: GraphicEnumMetadata<Graphic3D.Lookup3DAxis> = .init(value: .y)

        public func render(
            with graphic: Graphic3D,
            modifier modifierGraphic: Graphic3D,
            options: Graphic3D.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic3D {
           
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
