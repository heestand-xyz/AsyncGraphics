import SwiftUI
import Spatial
import CoreGraphics
import PixelColor

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class Clamp: ColorEffectGraphic3DProtocol {
        
        public var docs: String {
            "Apply various styles to colors outside of the set range."
        }
        
        public var style: GraphicEnumMetadata<Graphic.ClampType> = .init(value: .relative)
        
        public var low: GraphicMetadata<CGFloat> = .init(value: .zero)
        public var high: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var includeAlpha: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
             try await graphic.clamp(
                style.value,
                low: low.value.eval(at: graphic.resolution),
                high: high.value.eval(at: graphic.resolution),
                includeAlpha: includeAlpha.value.eval(at: graphic.resolution),
                options: options)
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case hold
            case loop
            case mirror
            case zero
            case relative
        }

        public func edit(variant: Variant) {
            low.value = .fixed(0.25)
            high.value = .fixed(0.75)
            switch variant {
            case .hold:
                style.value = .hold
            case .loop:
                style.value = .loop
            case .mirror:
                style.value = .mirror
            case .zero:
                style.value = .zero
            case .relative:
                style.value = .relative
            }
        }
    }
}
