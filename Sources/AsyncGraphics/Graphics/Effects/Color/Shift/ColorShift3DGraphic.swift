import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class ColorShift: ColorEffectGraphic3DProtocol {
        
        public var hue: GraphicMetadata<Angle> = .init()
        
        public var saturation: GraphicMetadata<CGFloat> = .init(value: .one,
                                                                maximum: .fixed(2.0))
        
        public var tintColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
            try await graphic.colorShift(
                hue: hue.value.eval(at: graphic.resolution),
                saturation: saturation.value.eval(at: graphic.resolution),
                tint: tintColor.value.eval(at: graphic.resolution))
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case monochrome
            case saturated
            case colorShift120
            case colorShift240
        }

        public func edit(variant: Variant) {
            switch variant {
            case .monochrome:
                saturation.value = .zero
            case .saturated:
                saturation.value = .fixed(2.0)
            case .colorShift120:
                hue.value = .fixed(.degrees(120))
            case .colorShift240:
                hue.value = .fixed(.degrees(240))
            }
        }
    }
}
