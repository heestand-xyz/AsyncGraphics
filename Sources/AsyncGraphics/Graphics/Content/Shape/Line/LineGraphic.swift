import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public class Line: ShapeContentGraphicProtocol {
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        var leadingPoint: GraphicMetadata<CGPoint> = .init(value: .resolutionAlignment(.leading))
        var trailingPoint: GraphicMetadata<CGPoint> = .init(value: .resolutionAlignment(.trailing))
        
        public var lineWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(10.0))
        
        public var lineCap: GraphicEnumMetadata<Graphic.LineCap> = .init(value: .square)
        
        public required init() {}
        
        public func render(
            at resolution: CGSize,
            options: AsyncGraphics.Graphic.ContentOptions = []
        ) async throws -> Graphic {
          
            try await .line(
                leadingPoint: leadingPoint.value.eval(at: resolution),
                trailingPoint: trailingPoint.value.eval(at: resolution),
                lineWidth: lineWidth.value.eval(at: resolution),
                cap: lineCap.value,
                color: foregroundColor.value.eval(at: resolution),
                backgroundColor: backgroundColor.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
