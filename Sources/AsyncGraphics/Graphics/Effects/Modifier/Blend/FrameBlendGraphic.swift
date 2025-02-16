import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class FrameBlend: ModifierEffectGraphicProtocol {
        
        public var docs: String {
            "Blend two graphics together and place the trailing graphic in a frame."
        }
        
        public var tags: [String] {
            Graphic.BlendMode.allCases.map(\.name)
        }
        
        public var blendingMode: GraphicEnumMetadata<Graphic.BlendMode> = .init(value: .add)
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public var alignment: GraphicEnumMetadata<Graphic.Alignment> = .init(value: .center)

        public var frame: GraphicMetadata<CGRect> = .init(
            value: .resolution,
            maximum: .resolution,
            options: .spatial)

        public var rotation: GraphicMetadata<Angle> = .init(
            value: .fixed(.zero))
        
        public var extendMode: GraphicEnumMetadata<Graphic.ExtendMode> = .init(
            value: .zero,
            docs: "Pixels outside the main bounds will use the extend mode when sampled. This will mainly affect pixels on the edges."
        )
        
        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
                       
            try await graphic.frameBlended(
                with: modifierGraphic,
                blendingMode: blendingMode.value,
                placement: placement.value,
                alignment: alignment.value,
                frame: frame.value.eval(at: graphic.resolution),
                rotation: rotation.value.eval(at: graphic.resolution),
                options: options.union(extendMode.value.options)
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
