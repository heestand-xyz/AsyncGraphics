import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Shape {
    
    @GraphicMacro
    public final class Box: ShapeContentGraphic3DProtocol {
        
        public var size: GraphicMetadata<SIMD3<Double>> = .init()
        public var position: GraphicMetadata<SIMD3<Double>> = .init()
        
        public var cornerRadius: GraphicMetadata<Double> = .init(value: .fixed(0.0),
                                                                 maximum: .resolutionMinimum(fraction: 0.5))
        
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
            
                try await .surfaceBox(
                    size: size.value.eval(at: resolution),
                    center: position.value.eval(at: resolution),
                    cornerRadius: cornerRadius.value.eval(at: resolution),
                    surfaceWidth: surfaceWidth.value.eval(at: resolution),
                    color: foregroundColor.value.eval(at: resolution),
                    backgroundColor: backgroundColor.value.eval(at: resolution),
                    resolution: resolution,
                    options: options)
                
            } else {
                
                try await .box(
                    size: size.value.eval(at: resolution),
                    center: position.value.eval(at: resolution),
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
