import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Convert {
    
    @GraphicMacro
    public final class Bits: ConvertEffectGraphicProtocol {
        
        public var bits: GraphicEnumMetadata<Graphic.Bits> = .init(value: .bit8)

        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.withBits(bits.value)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
