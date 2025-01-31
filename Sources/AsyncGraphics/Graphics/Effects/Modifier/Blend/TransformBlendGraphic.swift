import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class TransformBlend: ModifierEffectGraphicProtocol {
        
        public var docs: String {
            "Blend two graphics together and apply a transform to the trailing graphic."
        }
        
        public var tags: [String] {
            Graphic.BlendMode.allCases.map(\.name)
        }
        
        public var blendingMode: GraphicEnumMetadata<Graphic.BlendMode> = .init(value: .add)
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public var alignment: GraphicEnumMetadata<Graphic.Alignment> = .init(value: .center)
        
        public var translation: GraphicMetadata<CGPoint> = .init(
            value: .fixed(.zero),
            minimum: .resolutionMaximum(fraction: -0.5),
            maximum: .resolutionMaximum(fraction: 0.5),
            options: .spatial)

        public var rotation: GraphicMetadata<Angle> = .init(
            value: .fixed(.zero))
        
        public var scale: GraphicMetadata<CGFloat> = .init(
            value: .fixed(.one))
        
        public var size: GraphicMetadata<CGSize> = .init(
            value: .resolution,
            minimum: .fixed(.zero),
            maximum: .resolution,
            options: .spatial)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
                       
            try await graphic.transformBlended(
                with: modifierGraphic,
                blendingMode: blendingMode.value,
                placement: placement.value,
                alignment: alignment.value,
                translation: translation.value.eval(at: graphic.resolution),
                rotation: rotation.value.eval(at: graphic.resolution),
                scale: scale.value.eval(at: graphic.resolution),
                size: size.value.eval(at: graphic.resolution),
                options: options
            )
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
