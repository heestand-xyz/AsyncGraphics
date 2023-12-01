import SwiftUI

@GraphicTypeMacro
public enum ColorEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case channelMix
    case clamp
    case colorMap
    case colorShift
    case gradientLookup
    case levels
    case slope
}
