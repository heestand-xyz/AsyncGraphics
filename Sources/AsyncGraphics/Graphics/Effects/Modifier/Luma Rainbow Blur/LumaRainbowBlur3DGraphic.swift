import SwiftUI
import Spatial
import CoreGraphics

extension CodableGraphic3D.Effect.Modifier {
    
    @GraphicMacro
    public final class LumaRainbowBlur: ModifierEffectGraphic3DProtocol {
        
        public var docs: String {
            "Rainbow blur the first graphic based on the second graphic's luminance."
        }
        
        public var tags: [String] {
            ["Luminance"]
        }
        
        public var style: GraphicEnumMetadata<Graphic3D.LumaRainbowBlur3DType> = .init(value: .circle)
        
        public var radius: GraphicMetadata<CGFloat> = .init(value: .resolutionMinimum(fraction: 0.1),
                                                            maximum: .resolutionMinimum(fraction: 0.5),
                                                            options: .spatial)
        
        public var position: GraphicMetadata<Point3D> = .init(options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
        
        public var light: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                           maximum: .fixed(2.0))
        
        public var lumaGamma: GraphicMetadata<CGFloat> = .init(value: .fixed(1.0),
                                                               maximum: .fixed(2.0),
                                                               docs: "Adjustment of light on the modifier graphic.")
        
        public var sampleCount: GraphicMetadata<Int> = .init(value: .fixed(100),
                                                             minimum: .fixed(1),
                                                             maximum: .fixed(100))
        
        public var placement: GraphicEnumMetadata<Graphic.Placement> = .init(value: .fill)
        
        public var extendMode: GraphicEnumMetadata<Graphic.ExtendMode> = .init(
            value: .stretch,
            docs: "Voxels outside the main bounds will use the extend mode when sampled. This will mainly affect voxels on the edges."
        )
        
        public func render(
            with graphic: Graphic3D,
            modifier modifierGraphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
           
            try await graphic.lumaRainbowBlurred(
                with: modifierGraphic,
                type: style.value,
                radius: radius.value.eval(at: graphic.resolution),
                position: position.value.eval(at: graphic.resolution),
                angle: rotation.value.eval(at: graphic.resolution),
                light: light.value.eval(at: graphic.resolution),
                lumaGamma: lumaGamma.value.eval(at: graphic.resolution),
                sampleCount: sampleCount.value.eval(at: graphic.resolution),
                placement: placement.value,
                options: options.union(extendMode.value.options3D))
        }
        
        public func isVisible(property: Property, at resolution: CGSize) -> Bool {
            switch property {
            case .style:
                true
            case .radius:
                true
            case .position:
                style.value == .zoom
            case .rotation:
                style.value == .circle
            case .light:
                true
            case .lumaGamma:
                true
            case .sampleCount:
                true
            case .placement:
                true
            case .extendMode:
                true
            }
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case circle
            case zoom
        }

        public func edit(variant: Variant) {
            switch variant {
            case .circle:
                style.value = .circle
            case .zoom:
                style.value = .zoom
            }
        }
    }
}
