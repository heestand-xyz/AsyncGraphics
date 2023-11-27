import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Shape {
    
    @GraphicMacro
    public final class Cylinder: ShapeContentGraphic3DProtocol {
        
        public var position: GraphicMetadata<SIMD3<Double>> = .init()
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.5),
                                                            maximum: .resolutionMaximum(fraction: 0.5))
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public var surface: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var surfaceWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                                  maximum: .fixed(10.0))
        
        public func render(
            at resolution: SIMD3<Int>,
            options: Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
          
            if surface.value.eval(at: resolution) {
                
                try await .surfaceCylinder(
                    radius: radius.value.eval(at: resolution),
                    center: position.value.eval(at: resolution),
                    surfaceWidth: surfaceWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
                
            } else {
                
                try await .cylinder(
                    radius: radius.value.eval(at: resolution),
                    center: position.value.eval(at: resolution),
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
                radius.value = .resolutionMinimum(fraction: 0.25)
            }
        }
    }
}
