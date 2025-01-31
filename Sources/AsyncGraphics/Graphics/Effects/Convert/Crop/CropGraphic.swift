import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Convert {
    
    @GraphicMacro
    public final class Crop: ConvertEffectGraphicProtocol {
        
        public var fromLeft: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .width,
            options: .spatial)
        
        public var fromRight: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .width,
            options: .spatial)
        
        public var fromTop: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .height,
            options: .spatial)
        
        public var fromBottom: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .height,
            options: .spatial)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.crop(
                to: CGRect(
                    origin: CGPoint(
                        x: fromLeft.value.eval(at: graphic.resolution),
                        y: fromTop.value.eval(at: graphic.resolution)
                    ),
                    size: CGSize(
                        width: max(1, graphic.resolution.width - fromLeft.value.eval(at: graphic.resolution) - fromRight.value.eval(at: graphic.resolution)),
                        height: max(1, graphic.resolution.height - fromTop.value.eval(at: graphic.resolution) - fromBottom.value.eval(at: graphic.resolution))
                    )
                ),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
    }
}
