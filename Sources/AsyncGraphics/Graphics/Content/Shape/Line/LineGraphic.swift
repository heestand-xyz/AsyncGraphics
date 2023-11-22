import CoreGraphics
import PixelColor

extension CodableGraphic2D {
    
    @GraphicMacro
    public class Line: ShapeGraphic2DProtocol {
        
        public var type: CodableGraphic2DType {
            .content(.shape(.line))
        }
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        var leadingPoint: GraphicMetadata<CGPoint> = .init(value: .resolutionAlignment(.leading))
        var trailingPoint: GraphicMetadata<CGPoint> = .init(value: .resolutionAlignment(.trailing))
        
        public var lineWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(10.0))
        
        public var lineCap: GraphicEnumMetadata<Graphic.LineCap> = .init(value: .square)
        
        public func render(
            at resolution: CGSize,
            options: AsyncGraphics.Graphic.ContentOptions = []
        ) async throws -> Graphic {
            try await .line(
                leadingPoint: leadingPoint.value.at(resolution: resolution),
                trailingPoint: trailingPoint.value.at(resolution: resolution),
                lineWidth: lineWidth.value.at(resolution: resolution),
                cap: lineCap.value,
                color: foregroundColor.value.at(resolution: resolution),
                backgroundColor: backgroundColor.value.at(resolution: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
