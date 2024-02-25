import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Shape {
    
    @GraphicMacro
    public final class Cone: ShapeContentGraphic3DProtocol {
        
        public var axis: GraphicEnumMetadata<Graphic3D.Axis> = .init(value: .z)
        
        public var position: GraphicMetadata<Point3D> = .init(options: .spatial)
        
        public var length: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 1.0),
                                                            maximum: .resolutionMaximum(fraction: 1.0),
                                                            options: .spatial)
        
        public var leadingRadius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.5),
                                                                   maximum: .resolutionMaximum(fraction: 0.5),
                                                                   options: .spatial)
        
        public var trailingRadius: GraphicMetadata<CGFloat> = .init(value: .zero,
                                                                    maximum: .resolutionMaximum(fraction: 0.5),
                                                                    options: .spatial)
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white)){
            didSet {
                let fgColor: PixelColor = foregroundColor.value.eval(at: CGSize.one)
                let bgColor: PixelColor = backgroundColor.value.eval(at: CGSize.one)
                if bgColor.alpha == 0.0 {
                    backgroundColor.value = .fixed(fgColor.withAlpha(of: 0.0))
                }
            }
        }
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clearWhite))
        
        public var surface: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var surfaceWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                                  maximum: .fixed(10.0),
                                                                  options: .spatial)
        
        public func render(
            at resolution: Size3D,
            options: Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
          
            if surface.value.eval(at: resolution) {
                
                try await .surfaceCone(
                    axis: axis.value,
                    length: length.value.eval(at: resolution),
                    leadingRadius: leadingRadius.value.eval(at: resolution),
                    trailingRadius: trailingRadius.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
                    surfaceWidth: surfaceWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
                
            } else {
                
                try await .cone(
                    axis: axis.value,
                    length: length.value.eval(at: resolution),
                    leadingRadius: leadingRadius.value.eval(at: resolution),
                    trailingRadius: trailingRadius.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                leadingRadius.value = .resolutionMinimum(fraction: 0.25)
                length.value = .resolutionMinimum(fraction: 0.5)
            }
        }
    }
}
