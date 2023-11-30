import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Color {
    
    @GraphicMacro
    public final class Levels: ColorEffectGraphicProtocol {
        
        public var brightness: GraphicMetadata<CGFloat> = .init(value: .one,
                                                                maximum: .fixed(2.0))
        public var darkness: GraphicMetadata<CGFloat> = .init(value: .zero)
        
        public var contrast: GraphicMetadata<CGFloat> = .init(value: .zero)
        
        public var gamma: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public var isInverted: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public var isSmooth: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public var opacity: GraphicMetadata<CGFloat> = .init(value: .one)
        
        public var offset: GraphicMetadata<CGFloat> = .init(value: .zero)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.levels(
                brightness: brightness.value.eval(at: graphic.resolution),
                darkness: darkness.value.eval(at: graphic.resolution),
                contrast: contrast.value.eval(at: graphic.resolution),
                gamma: gamma.value.eval(at: graphic.resolution),
                invert: isInverted.value.eval(at: graphic.resolution),
                smooth: isSmooth.value.eval(at: graphic.resolution),
                opacity: opacity.value.eval(at: graphic.resolution),
                offset: offset.value.eval(at: graphic.resolution))
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case bright
            case dim
            case dark
            case contrast
            case smooth
            case gammaHalf
            case gammaDouble
            case semiTransparent
            case inverted
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .bright:
                brightness.value = .fixed(2.0)
            case .dim:
                brightness.value = .fixed(0.5)
            case .dark:
                darkness.value = .fixed(0.5)
            case .contrast:
                contrast.value = .fixed(0.5)
            case .smooth:
                isSmooth.value = .fixed(true)
            case .gammaHalf:
                gamma.value = .fixed(0.5)
            case .gammaDouble:
                gamma.value = .fixed(2.0)
            case .semiTransparent:
                opacity.value = .fixed(0.5)
            case .inverted:
                isInverted.value = .fixed(true)
            }
        }
    }
}
