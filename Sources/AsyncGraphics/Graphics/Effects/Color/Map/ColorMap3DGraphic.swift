import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class ColorMap: ColorEffectGraphic3DProtocol {
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
             try await graphic.colorMap(
                from: backgroundColor.value.eval(at: graphic.resolution),
                to: foregroundColor.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case red
            case green
            case blue
        }

        public func edit(variant: Variant) {
            switch variant {
            case .red:
                foregroundColor.value = .fixed(.rawRed)
            case .green:
                foregroundColor.value = .fixed(.rawGreen)
            case .blue:
                foregroundColor.value = .fixed(.rawBlue)
            }
        }
    }
}
