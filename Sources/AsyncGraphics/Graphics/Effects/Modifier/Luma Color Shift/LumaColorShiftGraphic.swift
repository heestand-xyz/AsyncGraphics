import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaColorShift: ModifierEffectGraphicProtocol {
        
        public var saturation: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                                maximum: .fixed(2.0))
        
        public var hue: GraphicMetadata<Angle> = .init()
        
        public var tintColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
           
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
            case hue120
            case hue240
            case saturation50
            case saturation200
        }

        public func edit(variant: Variant) {
            switch variant {
            case .hue120:
                hue.value = .fixed(.degrees(120))
            case .hue240:
                hue.value = .fixed(.degrees(240))
            case .saturation50:
                saturation.value = .fixed(0.5)
            case .saturation200:
                saturation.value = .fixed(2.0)
            }
        }
    }
}
