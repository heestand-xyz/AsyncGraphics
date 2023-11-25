import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Solid {
    
    @GraphicMacro
    public final class Color: SolidContentGraphic3DProtocol {
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public func render(
            at resolution: SIMD3<Int>,
            options: Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
           
            try await .color(
                color.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
        
        @VariantMacro
        enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            }
        }
    }
}
