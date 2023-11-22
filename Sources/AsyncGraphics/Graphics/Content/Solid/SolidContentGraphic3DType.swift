import SwiftUI

@GraphicTypeMacro
public enum SolidContentGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case color
    case gradient
    case noise
}
