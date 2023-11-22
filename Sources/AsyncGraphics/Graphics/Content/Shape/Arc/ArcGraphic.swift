import CoreGraphics
import PixelColor
import SwiftUI

extension CodableGraphic {
    
    @GraphicMacro
    public class Arc: ShapeGraphicProtocol {
        
        public var type: CodableGraphicType {
            .content(.shape(.arc))
        }
        
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
            if isStroked.value.at(resolution: resolution) {
                return try await .strokedArc(
                    angle: angle.value.at(resolution: resolution),
                    length: length.value.at(resolution: resolution),
                    radius: radius.value.at(resolution: resolution),
                    center: position.value.at(resolution: resolution),
                    lineWidth: lineWidth.value.at(resolution: resolution),
                    color: foregroundColor.value.at(resolution: resolution),
                    backgroundColor: backgroundColor.value.at(resolution: resolution),
                    resolution: resolution,
                    options: options)
            } else {
                return try await .arc(
                    angle: angle.value.at(resolution: resolution),
                    length: length.value.at(resolution: resolution),
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
