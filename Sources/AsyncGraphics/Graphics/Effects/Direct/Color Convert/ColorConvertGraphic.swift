import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public final class ColorConvert: DirectEffectGraphicProtocol {
        
        public var conversion: GraphicEnumMetadata<Graphic.ColorConversion> = .init(value: .rgbToHSV)
        
        public var channel: GraphicEnumMetadata<Graphic.ColorConvertChannel> = .init(value: .all)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
             try await graphic.colorConvert(
                conversion.value,
                channel: channel.value)
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
