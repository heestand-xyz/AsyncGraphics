import SwiftUI
import CoreGraphics
import PixelColor

extension CodableGraphic.Effect.Direct {
    
    @GraphicMacro
    public class ColorConvert: DirectEffectGraphicProtocol {
        
        public var conversion: GraphicEnumMetadata<Graphic.ColorConversion> = .init(value: .rgbToHSV)
        
        public var channel: GraphicEnumMetadata<Graphic.ColorConvertChannel> = .init(value: .all)
        
        public func render(
            with graphic: Graphic,
            options: Graphic.EffectOptions = []
        ) async throws -> Graphic {
            
             try await graphic.colorConvert(
                conversion.value,
                channel: channel.value)
        }
    }
}
