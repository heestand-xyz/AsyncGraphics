import CoreGraphics
import PixelColor
import SwiftUI

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public final class Arc: ShapeContentGraphicProtocol {
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.5),
                                                            maximum: .resolutionMaximum(fraction: 0.5),
                                                            options: .spatial)
        
        public var angle: GraphicMetadata<Angle> = .init(value: .fixed(.degrees(-90)),
                                                         docs: "Center of the arc.")
        public var length: GraphicMetadata<Angle> = .init(value: .fixed(.degrees(90)),
                                                          minimum: .fixed(.zero),
                                                          maximum: .fixed(.degrees(360)),
                                                          options: .spatial,
                                                          docs: "The angle length of the arc.")
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public var isStroked: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var lineWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(10.0),
                                                               maximum: .fixed(20.0),
                                                               options: .spatial)
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
            
            if isStroked.value.eval(at: resolution) {
            
                try await .strokedArc(
                    angle: angle.value.eval(at: resolution),
                    length: length.value.eval(at: resolution),
                    radius: radius.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
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
                    position: position.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case length45
            case length90
            case length120
            case length180
        }

        public func edit(variant: Variant) {
            switch variant {
            case .length45:
                length.value = .fixed(.degrees(45))
            case .length90:
                length.value = .fixed(.degrees(90))
            case .length120:
                length.value = .fixed(.degrees(120))
            case .length180:
                length.value = .fixed(.degrees(180))
            }
        }
    }
}
