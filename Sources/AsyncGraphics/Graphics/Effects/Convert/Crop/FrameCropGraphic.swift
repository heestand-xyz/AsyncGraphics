import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Convert {
    
    @GraphicMacro
    public final class FrameCrop: ConvertEffectGraphicProtocol {
        
        public var frame: GraphicMetadata<CGRect> = .init(
            value: .resolution,
            maximum: .resolution,
            options: .spatial)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.crop(
                to: frame.value.eval(at: graphic.resolution),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
