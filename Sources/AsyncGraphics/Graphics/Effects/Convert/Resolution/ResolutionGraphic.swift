import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Convert {
    
    @GraphicMacro
    public final class Resolution: ConvertEffectGraphicProtocol {
        
        public var resolution: GraphicMetadata<CGSize> = .init(
            value: .resolution,
            minimum: .one,
            maximum: .resolution,
            options: .spatial)
        
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
