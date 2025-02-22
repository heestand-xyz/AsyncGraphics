import SwiftUI
import PixelColor
import CoreGraphics

extension CodableGraphic.Effect.Convert {
    
    @GraphicMacro
    public final class CornerPin: ConvertEffectGraphicProtocol {
        
        public var topLeft: GraphicMetadata<CGPoint> = .init(
            value: .resolutionAlignment(.topLeading),
            minimum: .resolutionZero,
            maximum: .resolution,
            options: .spatial)
        
        public var topRight: GraphicMetadata<CGPoint> = .init(
            value: .resolutionAlignment(.topTrailing),
            minimum: .resolutionZero,
            maximum: .resolution,
            options: .spatial)
        
        public var bottomLeft: GraphicMetadata<CGPoint> = .init(
            value: .resolutionAlignment(.bottomLeading),
            minimum: .resolutionZero,
            maximum: .resolution,
            options: .spatial)
        
        public var bottomRight: GraphicMetadata<CGPoint> = .init(
            value: .resolutionAlignment(.bottomTrailing),
            minimum: .resolutionZero,
            maximum: .resolution,
            options: .spatial)
        
        public var perspective: GraphicMetadata<Bool> = .init(
            value: .fixed(true),
            docs: "Calculates a perspective correct corner pin. Useful when projection mapping from an angle.")
        
        public var subdivisions: GraphicMetadata<Int> = .init(
            value: .fixed(32),
            minimum: .fixed(8),
            maximum: .fixed(64),
            docs: "A higher value increases the quality of the perspective.")
        
        public var backgroundColor: GraphicMetadata<PixelColor> = .init(
            value: .fixed(.clear))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.cornerPinned(
                topLeft: topLeft.value.eval(at: graphic.resolution),
                topRight: topRight.value.eval(at: graphic.resolution),
                bottomLeft: bottomLeft.value.eval(at: graphic.resolution),
                bottomRight: bottomRight.value.eval(at: graphic.resolution),
                perspective: perspective.value.eval(at: graphic.resolution),
                subdivisions: subdivisions.value.eval(at: graphic.resolution),
                backgroundColor: backgroundColor.value.eval(at: graphic.resolution)
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
