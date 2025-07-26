import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class BayerDither: ColorEffectGraphicProtocol {
        
        public var docs: String {
            "Applies ordered Bayer dithering to the image with adjustable strength, levels, and optional monochrome output."
        }
        
        public var tags: [String] {
            []
        }
        
        public var strength: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                              maximum: .fixed(2.0))
        
        public var levels: GraphicMetadata<Int> = .init(value: .fixed(2),
                                                        minimum: .fixed(2),
                                                        maximum: .fixed(10))
        
        public var monochrome: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.bayerDithered(
                levels: levels.value.eval(at: graphic.resolution),
                strength: strength.value.eval(at: graphic.resolution),
                monochrome: monochrome.value.eval(at: graphic.resolution),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
