import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public class Color: SolidContentGraphicProtocol {
        
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
    }
}
