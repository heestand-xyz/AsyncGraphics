import CoreGraphics
import PixelColor

extension CodableGraphic3D.Content.Solid {
    
    @GraphicMacro
    public class Color: SolidGraphic3DProtocol {
        
        public var type: CodableGraphic3DType {
            .content(.solid(.color))
        }
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public required init() {}
        
        public func render(
            at resolution: SIMD3<Int>,
            options: AsyncGraphics.Graphic3D.ContentOptions = []
        ) async throws -> Graphic3D {
           
            try await .color(
                color.value.eval(at: resolution),
                resolution: resolution,
                options: options)
        }
    }
}
