import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class Range: ColorEffectGraphic3DProtocol {
        
        public var docs: String {
            "Range a graphics colors from a reference low and high to a target low and high."
        }
        
        public var referenceLow: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var referenceHigh: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var targetLow: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var targetHigh: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var includeAlpha: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
            try await graphic.range(
               referenceLow: referenceLow.value.eval(at: graphic.resolution),
               referenceHigh: referenceHigh.value.eval(at: graphic.resolution),
               includeAlpha: includeAlpha.value.eval(at: graphic.resolution),
               options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {}
    }
}
