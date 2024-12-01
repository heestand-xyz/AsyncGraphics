import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Space {
    
    @GraphicMacro
    public final class Sharpen: SpaceEffectGraphicProtocol {
        
        public var docs: String {
            "Add contrast on the pixel level."
        }
        
        public var tags: [String] {
            ["Contrast"]
        }
        
        public var sharpness: GraphicMetadata<CGFloat> = .init()
        
        public var distance: GraphicMetadata<CGFloat> = .init(value: .one,
                                                              maximum: .fixed(2.0),
                                                              options: .spatial)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.sharpen(
                sharpness.value.eval(at: graphic.resolution),
                distance: distance.value.eval(at: graphic.resolution),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
        
        public func edit(variant: Variant) {}
    }
}
