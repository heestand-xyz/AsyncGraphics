import CoreGraphics
import PixelColor

extension CodableGraphic.Content.Solid {
    
    @GraphicMacro
    public class Noise: SolidContentGraphicProtocol {
        
        public var type: CodableGraphicType {
            .content(.solid(.noise))
        }
        
        public required init() {}
        
        public func render(
            at resolution: CGSize,
            options: AsyncGraphics.Graphic.ContentOptions = []
        ) async throws -> Graphic {
           
            fatalError()
        }
    }
}
