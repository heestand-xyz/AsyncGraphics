import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class Slope: ColorEffectGraphic3DProtocol {
        
        public var amplitude: GraphicMetadata<CGFloat> = .init(value: .fixed(100.0),
                                                               maximum: .fixed(100.0))
        
        public var originColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.rawGray))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
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
