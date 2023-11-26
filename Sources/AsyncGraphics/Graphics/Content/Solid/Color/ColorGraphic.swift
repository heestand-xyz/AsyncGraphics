import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public final class Color: SolidContentGraphicProtocol {
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public func render(
            at resolution: CGSize,
            options: Graphic.ContentOptions = []
        ) async throws -> Graphic {
           
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
