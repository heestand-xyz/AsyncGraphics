import CoreGraphics
import PixelColor

extension CodableGraphic2D {
    
    @GraphicMacro
    public class Color: SolidGraphic2DProtocol {
        
        public var type: CodableGraphic2DType {
            .content(.solid(.color))
        }
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public func render(
            at resolution: CGSize,
            options: AsyncGraphics.Graphic.ContentOptions = []
        ) async throws -> Graphic {
            try await .color(
                color.value.at(resolution: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
