import CoreGraphics
import Spatial

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
        public enum Variant: String, GraphicVariant {
            case redGreen
            case greenBlue
            case blueRed
        }

        public func edit(variant: Variant) {
            switch variant {
            case .redGreen:
                red.value = .green
                green.value = .red
            case .greenBlue:
                green.value = .blue
                blue.value = .green
            case .blueRed:
                blue.value = .red
                red.value = .blue
            }
        }
    }
}
