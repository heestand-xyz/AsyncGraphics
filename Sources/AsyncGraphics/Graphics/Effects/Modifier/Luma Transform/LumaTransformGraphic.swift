import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaTransform: ModifierEffectGraphicProtocol {
        
        public var docs: String {
            "Transform the first graphic based on the second graphic's luminance."
        }
        
        public var tags: [String] {
            ["Luminance"]
        }
        
        public var translation: GraphicMetadata<CGPoint> = .init(value: .zero,
                                                                 minimum: .resolutionMaximum(fraction: -0.5),
                                                                 maximum: .resolutionMaximum(fraction: 0.5),
                                                                 options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
                
        public var scale: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public var scaleSize: GraphicMetadata<CGSize> = .init(value: .one,
                                                              maximum: .fixed(CGSize(width: 2.0,
                                                                                     height: 2.0)))
        
        public var isTransparent: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0),
                                                               docs: "Adjustment of light on the modifier graphic.")
        
        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.lumaTransformed(
                with: modifierGraphic,
                translation: translation.value.eval(at: graphic.resolution),
                rotation: rotation.value.eval(at: graphic.resolution),
                scale: scale.value.eval(at: graphic.resolution),
                scaleSize: scaleSize.value.eval(at: graphic.resolution),
                lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                placement: placement.value,
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
            case scaledDown
            case scaledUp
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            case .scaledDown:
                scale.value = .fixed(0.5)
            case .scaledUp:
                scale.value = .fixed(2.0)
            }
        }
    }
}
