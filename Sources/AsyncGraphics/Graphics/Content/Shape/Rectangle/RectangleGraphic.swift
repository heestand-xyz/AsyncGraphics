import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Shape {
    
    @GraphicMacro
    public final class Rectangle: ShapeContentGraphicProtocol {
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var size: GraphicMetadata<CGSize> = .init(options: .spatial)

        public var cornerRadius: GraphicMetadata<Double> = .init(value: .fixed(0.0),
                                                                 maximum: .resolutionMinimum(fraction: 0.5),
                                                                 options: .spatial)
        
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
                
                try await .strokedRectangle(
                    size: size.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
                    cornerRadius: cornerRadius.value.eval(at: resolution),
                    lineWidth: lineWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
                
            } else {
                
                try await .rectangle(
                    size: size.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
                    cornerRadius: cornerRadius.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
            case rounded
        }

        public func edit(variant: Variant) {
            size.value = .resolutionMinimum(fraction: 0.5)
            switch variant {
            case .regular:
                break
            case .rounded:
                cornerRadius.value = .resolutionMinimum(fraction: 1.0 / 8)
            }
        }
    }
}
