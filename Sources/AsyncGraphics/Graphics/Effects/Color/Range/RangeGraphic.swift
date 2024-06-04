import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class Range: ColorEffectGraphicProtocol {
        
        public var docs: String {
            "Range a graphics colors from a reference low and high to a target low and high."
        }
        
        public var referenceLow: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var referenceHigh: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var targetLow: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var targetHigh: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var includeAlpha: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
             try await graphic.range(
                referenceLow: referenceLow.value.eval(at: graphic.resolution),
                referenceHigh: referenceHigh.value.eval(at: graphic.resolution),
                includeAlpha: includeAlpha.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {}
    }
}
