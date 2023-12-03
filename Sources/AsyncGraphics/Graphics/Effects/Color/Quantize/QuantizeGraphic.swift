import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class Quantize: ColorEffectGraphic3DProtocol {
        
        public var fraction: GraphicMetadata<CGFloat> = .init(value: .fixed(0.25))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
             try await graphic.quantize(
                fraction.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case half
            case quarter
            case eight
        }

        public func edit(variant: Variant) {
            switch variant {
            case .half:
                fraction.value = .fixed(1.0 / 2)
            case .quarter:
                fraction.value = .fixed(1.0 / 4)
            case .eight:
                fraction.value = .fixed(1.0 / 8)
            }
        }
    }
}
