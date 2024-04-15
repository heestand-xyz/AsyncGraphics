import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Convert {
    
    @GraphicMacro
    public final class Bits: ConvertEffectGraphic3DProtocol {
        
        public var bits: GraphicEnumMetadata<Graphic.Bits> = .init(value: .bit8)

        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
            try await graphic.withBits(bits.value)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
