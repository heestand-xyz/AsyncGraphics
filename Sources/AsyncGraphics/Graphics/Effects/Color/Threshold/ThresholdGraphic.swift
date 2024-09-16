import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class Threshold: ColorEffectGraphicProtocol {

        public var docs: String {
            "Divide the graphic into two regions: one with a value below the threshold (background), and one with a value above (foreground)."
        }
        
        public var fraction: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5))
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.black))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.threshold(
                fraction.value.eval(at: graphic.resolution),
                color: foregroundColor.value.eval(at: graphic.resolution),
                backgroundColor: backgroundColor.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case low
            case mid
            case high
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .low:
                fraction.value = .fixed(0.25)
            case .mid:
                fraction.value = .fixed(0.5)
            case .high:
                fraction.value = .fixed(0.75)
            }
        }
    }
}
