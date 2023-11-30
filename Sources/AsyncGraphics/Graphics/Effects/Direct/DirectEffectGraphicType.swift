import SwiftUI

@GraphicTypeMacro
public enum DirectEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case blur
    case circleBlur
    case channelMix
    case chromaKey
    case clamp
    case colorConvert
    case colorMap
    case colorShift
    case edge
    case gradientLookup
}
