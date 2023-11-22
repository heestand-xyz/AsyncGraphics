import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public class Color: SolidGraphicProtocol {
        
        public var type: CodableGraphicType {
            .content(.solid(.color))
        }
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public required init() {}
        
        public func render(
            at resolution: CGSize,
            options: AsyncGraphics.Graphic.ContentOptions = []
        ) async throws -> Graphic {
           
            try await .color(
                color.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
