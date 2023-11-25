import SwiftUI
import CoreGraphics

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public final class ChannelMix: DirectEffectGraphicProtocol {
        
        public var red: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .red)
        
        public var green: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .green)
        
        public var blue: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .blue)
        
        public var alpha: GraphicEnumMetadata<Graphic.ColorChannel> = .init(value: .alpha)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
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
