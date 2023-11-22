import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Solid {
    
    @GraphicMacro
    public class Noise: SolidContentGraphic3DProtocol {
        
        public var type: CodableGraphic3DType {
            .content(.solid(.noise))
        }
        
        public required init() {}
        
        public func render(
            at resolution: SIMD3<Int>,
            options: AsyncGraphics.Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
           
            fatalError()
        }
    }
}
