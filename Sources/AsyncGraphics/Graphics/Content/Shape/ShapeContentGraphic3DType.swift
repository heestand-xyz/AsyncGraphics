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

extension ShapeContentGraphic3DType {
    
    public var symbolName: String {
        switch self {
        case .sphere:
            "circle"
        case .box:
            "square"
        case .cylinder:
            "capsule.portrait"
        case .torus:
            "circle.circle"
        case .cone:
            "triangle"
        case .tetrahedron:
            "triangle"
        }
    }
}
