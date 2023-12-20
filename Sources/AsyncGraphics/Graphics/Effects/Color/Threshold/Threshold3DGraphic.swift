import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class Threshold: ColorEffectGraphic3DProtocol {
        
        public var fraction: GraphicMetadata<CGFloat> = .init(value: .fixed(0.5))
        
        public var foregroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.white))
        
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(value: .fixed(.clearWhite))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
            try await graphic.threshold(
                fraction.value.eval(at: graphic.resolution),
                color: foregroundColor.value.eval(at: graphic.resolution),
                backgroundColor: backgroundColor.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case low
            case mid
            case high
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .low:
                fraction.value = .fixed(0.25)
            case .mid:
                fraction.value = .fixed(0.5)
            case .high:
                fraction.value = .fixed(0.75)
            }
        }
    }
}
