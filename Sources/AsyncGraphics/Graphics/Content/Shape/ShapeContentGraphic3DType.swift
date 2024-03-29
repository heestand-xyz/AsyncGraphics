import SwiftUI

@GraphicTypeMacro
public enum ShapeContentGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case sphere
    case box
    case cylinder
    case torus
    case cone
    case tetrahedron
}
