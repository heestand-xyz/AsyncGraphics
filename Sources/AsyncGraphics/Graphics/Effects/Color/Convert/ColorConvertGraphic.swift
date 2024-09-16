import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class ColorConvert: ColorEffectGraphicProtocol {
        
        public var docs: String {
            """
            Convert between color models.
            For HSV and the all channel option; hue is red, saturation is green, and value / brightness is blue.
            """
        }
        
        public var tags: [String] {
            ["RGB", "HSV", "Channels"]
        }
        
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
            case rgbToHSV
            case hsvToRGB
        }

        public func edit(variant: Variant) {
            switch variant {
            case .rgbToHSV:
                conversion.value = .rgbToHSV
            case .hsvToRGB:
                conversion.value = .hsvToRGB
            }
        }
    }
}
