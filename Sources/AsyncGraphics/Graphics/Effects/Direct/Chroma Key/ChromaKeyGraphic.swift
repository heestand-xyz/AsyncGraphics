import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public class ChromaKey: DirectEffectGraphicProtocol {
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.rawGreen))
        
        public var range: GraphicMetadata<CGFloat> = .init(value: .fixed(0.1))
        
        public var softness: GraphicMetadata<CGFloat> = .init(value: .fixed(0.1))
        
        public var edgeDesaturation: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5))
        
        public var alphaCrop: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5))
        
        public func parameters(at resolution: CGSize) -> Graphic.ChromaKeyParameters {
            var parameters = Graphic.ChromaKeyParameters()
            parameters.range = range.value.eval(at: resolution)
            parameters.softness = softness.value.eval(at: resolution)
            parameters.edgeDesaturation = edgeDesaturation.value.eval(at: resolution)
            parameters.alphaCrop = alphaCrop.value.eval(at: resolution)
            return parameters
        }
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
             try await graphic.chromaKey(
                color: color.value.eval(at: graphic.resolution),
                parameters: parameters(at: graphic.resolution),
                options: options)
        }
    }
}
