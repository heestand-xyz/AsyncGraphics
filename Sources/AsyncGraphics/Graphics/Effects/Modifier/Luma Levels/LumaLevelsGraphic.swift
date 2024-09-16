import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaLevels: ModifierEffectGraphicProtocol {
        
        public var docs: String {
            "Level the first graphic based on the second graphic's luminance."
        }
        
        public var tags: [String] {
            ["Luminance"]
        }
        
        public var brightness: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                                maximum: .fixed(2.0))
        
        public var darkness: GraphicMetadata<CGFloat> = .init()
        
        public var contrast: GraphicMetadata<CGFloat> = .init()
        
        public var gamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           docs: "Adjustment of light.")
        
        public var isInverted: GraphicMetadata<Bool> = .init()
        
        public var isSmooth: GraphicMetadata<Bool> = .init(docs: "Applies an s-curve of smooth contrast to the graphic. (With a sine curve)")
        
        public var opacity: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0))
        
        public var offset: GraphicMetadata<CGFloat> = .init(minimum: .fixed(-1.0),
                                                            docs: "Exposure offset. (With addition)")
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0),
                                                               docs: "Adjustment of light on the modifier graphic.")
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
           
            try await graphic.lumaLevels(
                with: modifierGraphic,
                brightness: brightness.value.eval(at: graphic.resolution),
                darkness: darkness.value.eval(at: graphic.resolution),
                contrast: contrast.value.eval(at: graphic.resolution),
                gamma: gamma.value.eval(at: graphic.resolution),
                invert: isInverted.value.eval(at: graphic.resolution),
                smooth: isSmooth.value.eval(at: graphic.resolution),
                opacity: opacity.value.eval(at: graphic.resolution),
                offset: offset.value.eval(at: graphic.resolution),
                lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                placement: placement.value,
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case bright
            case dim
            case dark
            case contrast
            case smooth
            case gammaHalf
            case gammaDouble
            case semiTransparent
            case inverted
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .bright:
                brightness.value = .fixed(2.0)
            case .dim:
                brightness.value = .fixed(0.5)
            case .dark:
                darkness.value = .fixed(0.5)
            case .contrast:
                contrast.value = .fixed(0.5)
            case .smooth:
                isSmooth.value = .fixed(true)
            case .gammaHalf:
                gamma.value = .fixed(0.5)
            case .gammaDouble:
                gamma.value = .fixed(2.0)
            case .semiTransparent:
                opacity.value = .fixed(0.5)
            case .inverted:
                isInverted.value = .fixed(true)
            }
        }
    }
}
