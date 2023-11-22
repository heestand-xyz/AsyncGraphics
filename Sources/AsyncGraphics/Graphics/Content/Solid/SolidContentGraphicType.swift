import SwiftUI

@GraphicTypeMacro
public enum SolidContentGraphicType: String, CodableGraphicTypeProtocol {
    
    case color
    case gradient
    case noise
}
