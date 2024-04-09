import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class GradientLookup: ColorEffectGraphicProtocol {
        
        public var docs: String {
            "Apply a gradient to a graphic, where the gradient's leading colors are applied the darker pixels, and the trailing colors are applied to the lighter pixels."
        }
        
        public var colorStops: GraphicMetadata<[Graphic.GradientStop]> = .init(value: .fixed([
            Graphic.GradientStop(at: 0.0, color: .black),
            Graphic.GradientStop(at: 1.0, color: .white),
        ]))
        
        public var gamma: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0),
                                                           docs: "Adjustment of light.")
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.gradientLookup(
                stops: colorStops.value.eval(at: graphic.resolution),
                gamma: gamma.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case fire
            case ice
            case rainbow
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .fire:
                colorStops.value = .fixed([
                    Graphic.GradientStop(at: 0.0, color: .black),
                    Graphic.GradientStop(at: 1.0 / 3.0, color: .rawRed),
                    Graphic.GradientStop(at: 2.0 / 3.0, color: .rawYellow),
                    Graphic.GradientStop(at: 1.0, color: .white),
                ])
            case .ice:
                colorStops.value = .fixed([
                    Graphic.GradientStop(at: 0.0, color: .black),
                    Graphic.GradientStop(at: 1.0 / 3.0, color: .rawBlue),
                    Graphic.GradientStop(at: 2.0 / 3.0, color: .rawCyan),
                    Graphic.GradientStop(at: 1.0, color: .white),
                ])
            case .rainbow:
                colorStops.value = .fixed([
                    Graphic.GradientStop(at: 0.0, color: .rawRed),
                    Graphic.GradientStop(at: 1.0 / 6.0, color: .rawYellow),
                    Graphic.GradientStop(at: 2.0 / 6.0, color: .rawGreen),
                    Graphic.GradientStop(at: 3.0 / 6.0, color: .rawCyan),
                    Graphic.GradientStop(at: 4.0 / 6.0, color: .rawBlue),
                    Graphic.GradientStop(at: 5.0 / 6.0, color: .rawMagenta),
                    Graphic.GradientStop(at: 1.0, color: .rawRed),
                ])
            }
        }
    }
}
