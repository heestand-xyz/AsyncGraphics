import SwiftUI

@GraphicTypeMacro
public enum SpaceEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case blur
    case circleBlur
    case edge
    case transform
}
