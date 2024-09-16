import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Space {
    
    @GraphicMacro
    public final class Morph: SpaceEffectGraphicProtocol {
        
        public var style: GraphicEnumMetadata<Graphic.MorphType> = .init(value: .maximum)
        
        public var size: GraphicMetadata<CGSize> = .init(value: .one,
                                                         maximum: .fixed(CGSize(width: 10, height: 10)))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.morphed(
                type: style.value,
                size: size.value.eval(at: graphic.resolution)
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
        
        public func edit(variant: Variant) {}
    }
}
