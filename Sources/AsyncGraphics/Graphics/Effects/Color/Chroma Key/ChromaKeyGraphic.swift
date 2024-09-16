import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class ChromaKey: ColorEffectGraphicProtocol {
        
        public var docs: String {
            "Green screen background removal."
        }
        
        public var tags: [String] {
            ["Green Screen", "Background Removal"]
        }
        
        public var color: GraphicMetadata<PixelColor> = .init(value: .fixed(.rawGreen),
                                                              docs: "Key color to remove.")
        
        public var range: GraphicMetadata<CGFloat> = .init(value: .fixed(0.1),
                                                           docs: "Hue range of the key color.")
        
        public var softness: GraphicMetadata<CGFloat> = .init(value: .fixed(0.1),
                                                              docs: "Smooths the alpha mask.")
        
        public var edgeDesaturation: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5),
                                                                      docs: "A higher value makes the edges of the alpha mask more monochrome.")
        
        public var alphaCrop: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5),
                                                               docs: "Clip semi transparent pixels.")
        
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
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case greenScreen
            case blueScreen
        }

        public func edit(variant: Variant) {
            switch variant {
            case .greenScreen:
                color.value = .fixed(.rawGreen)
            case .blueScreen:
                color.value = .fixed(.rawBlue)
            }
        }
    }
}
