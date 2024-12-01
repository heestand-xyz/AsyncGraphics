import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Space {
    
    @GraphicMacro
    public final class Kaleidoscope: SpaceEffectGraphicProtocol {
        
        public var count: GraphicMetadata<Int> = .init(value: .fixed(12),
                                                       maximum: .fixed(24))
        
        public var mirror: GraphicMetadata<Bool> = .init()
        
        public var position: GraphicMetadata<CGPoint> = .init(options: .spatial)
        
        public var rotation: GraphicMetadata<Angle> = .init()
        
        public var scale: GraphicMetadata<CGFloat> = .init(value: .one,
                                                           maximum: .fixed(2.0))
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = .edgeMirror
        ) async throws -> Graphic {
            
            try await graphic.kaleidoscope(
                count: count.value.eval(at: graphic.resolution),
                mirror: mirror.value.eval(at: graphic.resolution),
                position: position.value.eval(at: graphic.resolution),
                rotation: rotation.value.eval(at: graphic.resolution),
                scale: scale.value.eval(at: graphic.resolution),
                options: options
            )
        }
        
        @VariantMacro
        public enum Variant: String, GraphicVariant {
            case regular
        }
        
        public func edit(variant: Variant) {}
    }
}
