import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class ColorMap: ColorEffectGraphicProtocol {
        
        public var docs: String {
            "Map colors with a 2 stop gradient, from background to foreground."
        }
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.black))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
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
