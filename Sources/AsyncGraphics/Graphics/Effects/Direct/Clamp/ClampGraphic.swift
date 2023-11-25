import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public final class Clamp: DirectEffectGraphicProtocol {
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.rawGreen))
        
        public var style: GraphicEnumMetadata<Graphic.ClampType> = .init(value: .relative)
        
        public var low: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var high: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var includeAlpha: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
             try await graphic.clamp(
                style.value,
                low: low.value.eval(at: graphic.resolution),
                high: high.value.eval(at: graphic.resolution),
                includeAlpha: includeAlpha.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            }
        }
    }
}
