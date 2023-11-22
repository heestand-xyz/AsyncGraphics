import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public class Circle: ShapeGraphicProtocol {
        
        public var type: CodableGraphicType {
            .content(.shape(.circle))
        }
        
        public var position: GraphicMetadata<CGPoint> = .init()
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.5),
                                                            maximum: .resolutionMaximum(fraction: 0.5))
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public var isStroked: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var lineWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(10.0))
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
            if isStroked.value.at(resolution: resolution) {
                return try await .strokedCircle(
                    radius: radius.value.at(resolution: resolution),
                    center: position.value.at(resolution: resolution),
                    lineWidth: lineWidth.value.at(resolution: resolution),
                    color: foregroundColor.value.at(resolution: resolution),
                    backgroundColor: backgroundColor.value.at(resolution: resolution),
                    resolution: resolution,
                    options: options)
            } else {
                return try await .circle(
                    radius: radius.value.at(resolution: resolution),
                    center: position.value.at(resolution: resolution),
                    color: foregroundColor.value.at(resolution: resolution),
                    backgroundColor: backgroundColor.value.at(resolution: resolution),
                    resolution: resolution,
                    options: options)
            }
        }
    }
}
