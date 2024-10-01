import SwiftUI
import CoreGraphics
import Spatial

extension CodableGraphic3D.Effect.Convert {
    
    @GraphicMacro
    public final class Crop: ConvertEffectGraphic3DProtocol {
        
        public var fromLeft: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .width)
        
        public var fromRight: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .width)
        
        public var fromTop: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .height)
        
        public var fromBottom: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .height)
        
        public var fromFar: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .depth)
        
        public var fromNear: GraphicMetadata<CGFloat> = .init(
            value: .fixed(0),
            maximum: .depth)
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fit)
        
        public var interpolation: GraphicEnumMetadata<Graphic.ResolutionInterpolation> = .init(value: .linear)

        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
            
            try await graphic.crop(
                to: Rect3D(
                    origin: Point3D(
                        x: fromLeft.value.eval(at: graphic.resolution),
                        y: fromTop.value.eval(at: graphic.resolution),
                        z: fromFar.value.eval(at: graphic.resolution)
                    ),
                    size: Size3D(
                        width: max(1, graphic.resolution.width - fromLeft.value.eval(at: graphic.resolution) - fromRight.value.eval(at: graphic.resolution)),
                        height: max(1, graphic.resolution.height - fromTop.value.eval(at: graphic.resolution) - fromBottom.value.eval(at: graphic.resolution)),
                        depth: max(1, graphic.resolution.depth - fromFar.value.eval(at: graphic.resolution) - fromNear.value.eval(at: graphic.resolution))
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
