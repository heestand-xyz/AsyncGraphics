import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Modifier {
    
    @GraphicMacro
    public final class Displace: ModifierEffectGraphic3DProtocol {
        
        public var docs: String {
            "Displace the first graphic with the seconds graphics red (x), green (y) and blue (z) colors."
        }
        
        public var offset: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            options: .spatial)
        
        public var origin: GraphicMetadata<PixelColor> = .init(value: .fixed(.rawGray))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic3D,
            modifier modifierGraphic: Graphic3D,
            options: Graphic3D.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic3D {
           
            try await graphic.displaced(
                with: modifierGraphic,
                offset: offset.value.eval(at: graphic.resolution),
                origin: origin.value.eval(at: graphic.resolution),
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
