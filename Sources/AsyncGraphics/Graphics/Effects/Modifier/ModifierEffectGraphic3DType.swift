import SwiftUI

@GraphicTypeMacro
public enum ModifierEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case mask
    case cross
    case blend
    case displace
    case lookup
    case lumaBlur
    case lumaColorShift
}
