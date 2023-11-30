import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public final class Edge: DirectEffectGraphicProtocol {
        
        public var amplitude: GraphicMetadata<CGFloat> = .init(value: .one,
                                                               maximum: .fixed(2.0))
        
        public var distance: GraphicMetadata<CGFloat> = .init(value: .one,
                                                              maximum: .fixed(2.0))
                
        public var isColored: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public var isTransparent: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.edge(
                amplitude: amplitude.value.eval(at: graphic.resolution),
                distance: distance.value.eval(at: graphic.resolution),
                isColored: isColored.value.eval(at: graphic.resolution),
                isTransparent: isTransparent.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case monochrome
            case colored
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .monochrome:
                isColored.value = .fixed(false)
            case .colored:
                isColored.value = .fixed(true)
            }
        }
    }
}
