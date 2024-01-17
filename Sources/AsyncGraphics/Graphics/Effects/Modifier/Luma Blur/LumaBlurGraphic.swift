import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaBlur: ModifierEffectGraphicProtocol {
        
        public var style: GraphicEnumMetadata<Graphic.LumaBlurType> = .init(value: .box)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5),
                                                            options: .spatial)
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0))
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)

        public func render(
            with graphic: Graphic,
            modifier modifierGraphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
           
            switch style.value {
            case .box:
                
                try await graphic.lumaBlurredBox(
                    with: modifierGraphic,
                    radius: radius.value.eval(at: graphic.resolution),
                    lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    placement: placement.value,
                    options: options)
                
            case .angle:
                
                try await graphic.lumaBlurredAngle(
                    with: modifierGraphic,
                    radius: radius.value.eval(at: graphic.resolution),
                    angle: rotation.value.eval(at: graphic.resolution),
                    lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    placement: placement.value,
                    options: options)
                
            case .zoom:
                
                try await graphic.lumaBlurredZoom(
                    with: modifierGraphic,
                    radius: radius.value.eval(at: graphic.resolution),
                    position: position.value.eval(at: graphic.resolution),
                    lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                    sampleCount: sampleCount.value.eval(at: graphic.resolution),
                    placement: placement.value,
                    options: options)
                
            case .random:
                
                try await graphic.lumaBlurredRandom(
                    with: modifierGraphic,
                    radius: radius.value.eval(at: graphic.resolution),
                    lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                    placement: placement.value,
                    options: options)
            }
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
                style.value == .angle
            case .sampleCount:
                style.value != .random
            case .lumaGamma:
                true
            case .placement:
                true
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case light
            case medium
            case heavy
            case angle
            case zoom
            case random
        }

        public func edit(variant: Variant) {
            switch variant {
            case .light, .medium, .heavy:
                style.value = .box
            case .angle:
                style.value = .angle
            case .zoom:
                style.value = .zoom
            case .random:
                style.value = .random
            }
            switch variant {
            case .light:
                radius.value = .resolutionMinimum(fraction: 1.0 / 32)
            case .medium:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            case .heavy:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .angle:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            case .zoom:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .random:
                break
            }
        }
    }
}
