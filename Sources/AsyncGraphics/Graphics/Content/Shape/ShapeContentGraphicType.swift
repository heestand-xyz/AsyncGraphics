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
    
    public var symbolName: String {
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

extension ShapeContentGraphicType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .circle:
                .basic
        case .rectangle:
                .basic
        case .polygon:
                .basic
        case .star:
                .basic
        case .arc:
                .basic
        case .line:
                .basic
        }
    }
}
