import CoreGraphics
import Spatial

extension CodableGraphic3D.Effect.Color {
    
    @GraphicMacro
    public final class ChannelMix: ColorEffectGraphic3DProtocol {
        
        public var docs: String {
            "Mix red, green, blue and alpha channels."
        }
        
        public var red: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .red,
                                                                          docs: "The source of the red channel.")
        
        public var green: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .green,
                                                                            docs: "The source of the green channel.")
        
        public var blue: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .blue,
                                                                           docs: "The source of the blue channel.")
        
        public var alpha: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .alpha,
                                                                            docs: "The source of the alpha channel.")
        
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
