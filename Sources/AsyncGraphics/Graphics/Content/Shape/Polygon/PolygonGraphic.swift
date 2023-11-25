import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public class Polygon: ShapeContentGraphicProtocol {
        
        public var count: GraphicMetadata<Int> = .init(value: .fixed(3), 
                                                       minimum: .fixed(3),
                                                       maximum: .fixed(12))

        public var position: GraphicMetadata<CGPoint> = .init()
        
        public var rotation: GraphicMetadata<Angle> = .init()

        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.5),
                                                            maximum: .resolutionMaximum(fraction: 0.5))
        
        public var cornerRadius: GraphicMetadata<Double> = .init(value: .fixed(0.0),
                                                                 maximum: .resolutionMinimum(fraction: 0.5))
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
            
            try await .polygon(
                count: count.value.eval(at: resolution),
                radius: radius.value.eval(at: resolution),
                center: position.value.eval(at: resolution),
                rotation: rotation.value.eval(at: resolution),
                cornerRadius: cornerRadius.value.eval(at: resolution),
                color: foregroundColor.value.eval(at: resolution),
                backgroundColor: backgroundColor.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
