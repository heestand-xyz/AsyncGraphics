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

extension ShapeContentGraphicType {
    
    var symbolName: String {
        switch self {
        case .circle:
            "circle"
        case .rectangle:
            "rectangle"
        case .polygon:
            "triangle"
        case .star:
            "star"
        case .arc:
            "triangle"
        case .line:
            "line.diagonal"
        }
    }
}
