import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaRainbowBlur: ModifierEffectGraphicProtocol {
        
        public var style: GraphicEnumMetadata<Graphic.LumaRainbowBlurType> = .init(value: .circle)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5),
                                                            options: .spatial)
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
        
        public var light: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0),
                                                               docs: "Adjustment of light on the modifier graphic.")
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
           
            try await graphic.lumaRainbowBlurred(
                with: modifierGraphic,
                type: style.value,
                radius: radius.value.eval(at: graphic.resolution),
                position: position.value.eval(at: graphic.resolution),
                angle: rotation.value.eval(at: graphic.resolution),
                light: light.value.eval(at: graphic.resolution),
                lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                sampleCount: sampleCount.value.eval(at: graphic.resolution),
                placement: placement.value,
                options: options)
        }
        
        public func isVisible(property: Property, at resolution: CGSize) -> Bool {
            switch property {
            case .style:
                true
            case .radius:
                true
            case .position:
                style.value == .zoom
            case .rotation:
                [.angle, .circle].contains(style.value)
            case .light:
                true
            case .lumaGamma:
                true
            case .sampleCount:
                true
            case .placement:
                true
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case circle
            case angle
            case zoom
        }

        public func edit(variant: Variant) {
            switch variant {
            case .circle:
                style.value = .circle
            case .angle:
                style.value = .angle
            case .zoom:
                style.value = .zoom
            }
        }
    }
}
