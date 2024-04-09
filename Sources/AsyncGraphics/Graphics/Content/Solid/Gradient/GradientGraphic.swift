import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public final class Gradient: SolidContentGraphicProtocol {
        
        public var direction: GraphicEnumMetadata<Graphic.GradientDirection> = .init(value: .vertical)
        
        public var colorStops: GraphicMetadata<[Graphic.GradientStop]> = .init(value: .fixed([
            Graphic.GradientStop(at: 0.0, color: .black),
            Graphic.GradientStop(at: 1.0, color: .white),
        ]))
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var scale: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var offset: GraphicMetadata<CGFloat> = .init(value: .fixed(0.0),
                                                            minimum: .fixed(-1.0))
        
        public var gamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0),
                                                           docs: "Adjustment of light.")
        
        public var extend: GraphicEnumMetadata<Graphic.GradientExtend> = .init(value: .zero,
                                                                               docs: "Property for what to do with values extending above 1.0 and below 0.0. This property has no effect until position, scale or offset are modified.")
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
            
            try await .gradient(
                direction: direction.value,
                stops: colorStops.value.eval(at: resolution),
                position: position.value.eval(at: resolution),
                scale: scale.value.eval(at: resolution),
                offset: offset.value.eval(at: resolution),
                extend: extend.value,
                gamma: gamma.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case vertical
            case horizontal
            case radial
            case angle
        }

        public func edit(variant: Variant) {
            switch variant {
            case .vertical:
                direction.value = .vertical
            case .horizontal:
                direction.value = .horizontal
            case .radial:
                direction.value = .radial
            case .angle:
                direction.value = .angle
            }
        }
    }
}
