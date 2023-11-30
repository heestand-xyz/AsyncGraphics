import SwiftUI

@GraphicTypeMacro
public enum DirectEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case blur
    case channelMix
    case clamp
    case colorMap
    case colorShift
    case edge
    case gradientLookup
}
