import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Space {
    
    @GraphicMacro
    public final class Pixelate: SpaceEffectGraphicProtocol {
        
        public var fraction: GraphicMetadata<CGFloat> = .init(value: .fixed(0.1))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = .edgeStretch
        ) async throws -> Graphic {
            
            try await graphic.pixelate(
                fraction.value.eval(at: graphic.resolution),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
        
        public func edit(variant: Variant) {}
    }
}
