import SwiftUI

@GraphicTypeMacro
public enum ModifierEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case mask
    case cross
    case blend
    case displace
}
