import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Solid {
    
    @GraphicMacro
    public final class Color: SolidContentGraphic3DProtocol {
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public func render(
            at resolution: Size3D,
            options: Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
           
            try await .color(
                color.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case white
            case black
            case clear
        }

        public func edit(variant: Variant) {
            switch variant {
            case .white:
                color.value = .fixed(.white)
            case .black:
                color.value = .fixed(.black)
            case .clear:
                color.value = .fixed(.clear)
            }
        }
    }
}
