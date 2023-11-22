import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public class Circle: ShapeContentGraphicProtocol {
        
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
        
        public required init() {}
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
            
            if isStroked.value.eval(at: resolution) {
                
                try await .strokedCircle(
                    radius: radius.value.eval(at: resolution),
                    center: position.value.eval(at: resolution),
                    lineWidth: lineWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
                
            } else {
                
                try await .circle(
                    radius: radius.value.eval(at: resolution),
                    center: position.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
            }
        }
    }
}
