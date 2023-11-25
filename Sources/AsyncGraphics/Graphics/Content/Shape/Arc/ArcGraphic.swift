import CoreGraphics
import PixelColor
import SwiftUI

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public class Arc: ShapeContentGraphicProtocol {
        
        public var position: GraphicMetadata<CGPoint> = .init()
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.5),
                                                            maximum: .resolutionMaximum(fraction: 0.5))
        
        public var angle: GraphicMetadata<Angle> = .init()
        public var length: GraphicMetadata<Angle> = .init(value: .fixed(.degrees(90)),
                                                          minimum: .fixed(.zero),
                                                          maximum: .fixed(.degrees(360)))
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public var isStroked: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var lineWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(10.0))
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
            
            if isStroked.value.eval(at: resolution) {
            
                try await .strokedArc(
                    angle: angle.value.eval(at: resolution),
                    length: length.value.eval(at: resolution),
                    radius: radius.value.eval(at: resolution),
                    center: position.value.eval(at: resolution),
                    lineWidth: lineWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
                
            } else {
                
                try await .arc(
                    angle: angle.value.eval(at: resolution),
                    length: length.value.eval(at: resolution),
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
