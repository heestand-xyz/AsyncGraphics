import CoreGraphics
import simd

extension CodableGraphic3D.Effect.Direct {
    
    @GraphicMacro
    public final class ChannelMix: DirectEffectGraphic3DProtocol {
        
        public var red: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .red)
        
        public var green: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .green)
        
        public var blue: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .blue)
        
        public var alpha: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .alpha)
        
        public func render(
            with graphic: Graphic3D,
            options: Graphic3D.EffectOptions = []
        ) async throws -> Graphic3D {
           
            try await graphic.channelMix(
                red: red.value,
                green: green.value,
                blue: blue.value,
                alpha: alpha.value)
        }
        
        @VariantMacro
        enum Variant: String, GraphicVariant {
            case regular
        }

        public func edit(variant: Variant) {
            switch variant {
            case .regular:
                break
            }
        }
    }
}