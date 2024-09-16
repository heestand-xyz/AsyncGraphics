import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class Slope: ColorEffectGraphicProtocol {

        public var docs: String {
            "Calculate the slope between neighboring pixels by generating a normal map. 16 or 32 bit recommended."
        }
        
        public var tags: [String] {
            ["Normal Map"]
        }
        
        public var amplitude: GraphicMetadata<CGFloat> = .init(value: .fixed(100.0),
                                                               maximum: .fixed(100.0))
        
        public var originColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.rawGray))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.slope(
                amplitude: amplitude.value.eval(at: graphic.resolution),
                origin: originColor.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case one
            case ten
            case oneHundred
            case oneThousand
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .one:
                amplitude.value = .fixed(1.0)
            case .ten:
                amplitude.value = .fixed(10.0)
            case .oneHundred:
                amplitude.value = .fixed(100.0)
            case .oneThousand:
                amplitude.value = .fixed(1000.0)
            }
        }
    }
}
