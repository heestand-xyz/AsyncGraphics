import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Space {
    
    @GraphicMacro
    public final class RainbowBlur: SpaceEffectGraphicProtocol {
        
        public var docs: String {
            "Rainbow Blur a graphic."
        }
        
        public var tags: [String] {
            Graphic.RainbowBlurType.allCases.map(\.name)
        }
        
        public var style: GraphicEnumMetadata<Graphic.RainbowBlurType> = .init(value: .circle)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5),
                                                            options: .spatial)
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
        
        public var light: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public var extendMode: GraphicEnumMetadata<Graphic.ExtendMode> = .init(
            value: .stretch,
            docs: "Pixels outside the main bounds will use the extend mode when sampled. This will mainly affect pixels on the edges."
        )
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
           
            try await graphic.rainbowBlurred(
                type: style.value,
                radius: radius.value.eval(at: graphic.resolution),
                position: position.value.eval(at: graphic.resolution),
                angle: rotation.value.eval(at: graphic.resolution),
                light: light.value.eval(at: graphic.resolution),
                sampleCount: sampleCount.value.eval(at: graphic.resolution),
                options: options.union(extendMode.value.options))
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
                style.value == .angle || style.value == .circle
            case .light:
                true
            case .sampleCount:
                true
            case .extendMode:
                true
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case angle
            case zoom
            case circle
        }

        public func edit(variant: Variant) {
            switch variant {
            case .angle:
                style.value = .angle
            case .zoom:
                style.value = .zoom
            case .circle:
                style.value = .circle
            }
            switch variant {
            case .angle:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            case .zoom:
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
            case .circle:
                radius.value = .resolutionMinimum(fraction: 1.0 / 16)
            }
        }
    }
}
