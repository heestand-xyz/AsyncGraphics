import SwiftUI

@GraphicTypeMacro
public enum ShapeContentGraphicType: String, CodableGraphicTypeProtocol {
    
    case circle
    case rectangle
    case polygon
    case star
    case arc
    case line
}
