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

extension ShapeContentGraphic3DType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .sphere:
                .basic
        case .box:
                .basic
        case .cylinder:
                .basic
        case .torus:
                .basic
        case .cone:
                .basic
        case .tetrahedron:
                .basic
        }
    }
}
