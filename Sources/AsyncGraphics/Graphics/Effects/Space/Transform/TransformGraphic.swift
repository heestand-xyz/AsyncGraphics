import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Space {
    
    @GraphicMacro
    public final class Transform: SpaceEffectGraphicProtocol {
        
        public var tags: [String] {
            ["Translation", "Offset", "Position", "Size", "Scale", "Rotation"]
        }
        
        public var translation: GraphicMetadata<CGPoint> = .init(value: .zero,
                                                                 minimum: .resolutionMaximum(fraction: -0.5),
                                                                 maximum: .resolutionMaximum(fraction: 0.5),
                                                               options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
                
        public var scale: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public var size: GraphicMetadata<CGSize> = .init(value: .resolution,
                                                         maximum: .resolution,
                                                         options: .spatial)
        
        public var isTransparent: GraphicMetadata<Bool> = .init(value: .fixed(false))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
            try await graphic.transformed(
                translation: translation.value.eval(at: graphic.resolution),
                rotation: rotation.value.eval(at: graphic.resolution),
                scale: scale.value.eval(at: graphic.resolution),
                size: size.value.eval(at: graphic.resolution),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
            case scaledDown
            case scaledUp
        }
        
        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            case .scaledDown:
                scale.value = .fixed(0.5)
            case .scaledUp:
                scale.value = .fixed(2.0)
            }
        }
    }
}
