import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public class Gradient: SolidGraphicProtocol {
        
        public var type: CodableGraphicType {
            .content(.solid(.gradient))
        }
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public required init() {}
        
        public func render(
            at resolution: CGSize,
            options: AsyncGraphics.Graphic.ContentOptions = []
        ) async throws -> Graphic {
            fatalError()
        }
    }
}
