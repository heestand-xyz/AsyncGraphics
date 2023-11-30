import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public final class CircleBlur: DirectEffectGraphicProtocol {
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5))
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public var brightnessLow: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var brightnessHigh: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var saturationLow: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var saturationHigh: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var light: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = [.edgeStretch]
        ) async throws -> Graphic {
            
             try await graphic.blurredCircle(
                radius: radius.value.eval(at: graphic.resolution),
                sampleCount: sampleCount.value.eval(at: graphic.resolution),
                brightnessRange: brightnessLow.value.eval(at: graphic.resolution)...brightnessHigh.value.eval(at: graphic.resolution),
                saturationRange: saturationLow.value.eval(at: graphic.resolution)...saturationHigh.value.eval(at: graphic.resolution),
                light: light.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case light
            case medium
            case heavy
        }

        public func edit(variant: Variant) {
            switch variant {
            case .light:
                radius.value = .resolutionMinimum(fraction: 1.0 / 32)
            case .medium:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            case .heavy:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            }
        }
    }
}
