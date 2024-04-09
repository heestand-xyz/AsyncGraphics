import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public final class Line: ShapeContentGraphicProtocol {
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        var leadingPoint: GraphicMetadata<CGPoint> = .init(value: .resolutionAlignment(.leading),
                                                           options: .spatial)
        var trailingPoint: GraphicMetadata<CGPoint> = .init(value: .resolutionAlignment(.trailing),
                                                            options: .spatial)
        
        public var lineWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(10.0),
                                                               maximum: .fixed(20.0),
                                                               options: .spatial)
        
        public var lineCap: GraphicEnumMetadata<Graphic.LineCap> = .init(value: .square,
                                                                         docs: "The shape of the ends of the line.")
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
          
            try await .line(
                from: leadingPoint.value.eval(at: resolution),
                to: trailingPoint.value.eval(at: resolution),
                lineWidth: lineWidth.value.eval(at: resolution),
                cap: lineCap.value,
                color: foregroundColor.value.eval(at: resolution),
                backgroundColor: backgroundColor.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case horizontal
            case vertical
        }

        public func edit(variant: Variant) {
            switch variant {
            case .horizontal:
                leadingPoint.value = .resolutionAlignment(.leading)
                trailingPoint.value = .resolutionAlignment(.trailing)
            case .vertical:
                leadingPoint.value = .resolutionAlignment(.top)
                trailingPoint.value = .resolutionAlignment(.bottom)
            }
        }
    }
}
