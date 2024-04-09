import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class PersonSegmentation: ColorEffectGraphicProtocol {
        
        public var docs: String {
            "Background removal."
        }
        
        public var isMask: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            if isMask.value.eval(at: graphic.resolution) {
                try await graphic.personSegmentationMask()
            } else {
                try await graphic.personSegmentation()
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case transparent
            case mask
        }

        public func edit(variant: Variant) {
            switch variant {
            case .transparent:
                isMask.value = .fixed(false)
            case .mask:
                isMask.value = .fixed(true)
            }
        }
    }
}
