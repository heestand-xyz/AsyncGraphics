import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaColorShift: ModifierEffectGraphic3DProtocol {
        
        public var docs: String {
            "Shift colors in the first graphic based on the second graphic's luminance."
        }
        
        public var tags: [String] {
            ["Luminance"]
        }
        
        public var saturation: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                                maximum: .fixed(2.0))
        
        public var hue: GraphicMetadata<Angle> = .init()
        
        public var tintColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0),
                                                               docs: "Adjustment of light on the modifier graphic.")
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic3D,
            modifier modifierGraphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
           
            try await graphic.lumaColorShifted(
                with: modifierGraphic,
                hue: hue.value.eval(at: graphic.resolution),
                saturation: saturation.value.eval(at: graphic.resolution),
                tintColor: tintColor.value.eval(at: graphic.resolution),
                lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                placement: placement.value,
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case monochrome
            case saturated
            case hue120
            case hue240
        }

        public func edit(variant: Variant) {
            switch variant {
            case .monochrome:
                saturation.value = .fixed(0.0)
            case .saturated:
                saturation.value = .fixed(2.0)
            case .hue120:
                hue.value = .fixed(.degrees(120))
            case .hue240:
                hue.value = .fixed(.degrees(240))
            }
        }
    }
}
