import SwiftUI

@GraphicTypeMacro
public enum ColorEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case channelMix
    case chromaKey
    case clamp
    case colorConvert
    case colorMap
    case colorShift
    case gradientLookup
    case levels
    case quantize
    case personSegmentation
    case slope
}
