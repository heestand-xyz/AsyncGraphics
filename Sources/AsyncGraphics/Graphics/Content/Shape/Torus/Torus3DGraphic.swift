import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Shape {
    
    @GraphicMacro
    public final class Torus: ShapeContentGraphic3DProtocol {
        
        public var docs: String {
            "A 3D donut shape."
        }
        
        public var axis: GraphicEnumMetadata<Graphic3D.Axis> = .init(value: .z)
        
        public var position: GraphicMetadata<Point3D> = .init(options: .spatial)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 1.0 / 3),
                                                            maximum: .resolutionMinimum(fraction: 1.0 / 3),
                                                            options: .spatial)
        
        public var revolvingRadius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 1.0 / 6),
                                                                     maximum: .resolutionMinimum(fraction: 1.0 / 6),
                                                                     options: .spatial)
            
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clear))
        
        public var surface: GraphicMetadata<Bool> = .init(value: .fixed(false))
        public var surfaceWidth: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                                  maximum: .fixed(2.0),
                                                                  options: .spatial)
        
        public func render(
            at resolution: Size3D,
            options: Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
          
            if surface.value.eval(at: resolution) {
                
                try await .surfaceTorus(
                    axis: axis.value,
                    radius: radius.value.eval(at: resolution),
                    revolvingRadius: revolvingRadius.value.eval(at: resolution),
                    position: position.value.eval(at: resolution),
                    surfaceWidth: surfaceWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
                
            } else {
                
                try await .torus(
                    axis: axis.value,
                    radius: radius.value.eval(at: resolution),
                    revolvingRadius: revolvingRadius.value.eval(at: resolution),
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
                radius.value = .resolutionMinimum(fraction: 1.0 / 8)
                revolvingRadius.value = .resolutionMinimum(fraction: 1.0 / 16)
            }
        }
    }
}
