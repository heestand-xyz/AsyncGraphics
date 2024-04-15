import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Convert {
    
    @GraphicMacro
    public final class Resolution: ConvertEffectGraphicProtocol {
        
        public var resolution: GraphicMetadata<CGSize> = .init(
            value: .fixed(CGSize(width: 1000, height: 1000)),
            minimum: .fixed(CGSize(width: 1, height: 1)),
            maximum: .fixed(CGSize(width: 16_384, height: 16_384)))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fit)
        
        public var interpolation: GraphicEnumMetadata<Graphic.ResolutionInterpolation> = .init(value: .linear)

        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.resized(to: resolution.value.eval(at: graphic.resolution), placement: placement.value, interpolation: interpolation.value, options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
