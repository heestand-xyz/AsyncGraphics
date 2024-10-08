import SwiftUI

@GraphicTypeMacro
public enum SolidContentGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case color
    case gradient
    case noise
}

extension SolidContentGraphic3DType {
    
    public var symbolName: String {
        switch self {
        case .color:
            "paintpalette"
        case .gradient:
            "circle.and.line.horizontal"
        case .noise:
            "water.waves"
        }
    }
}

extension SolidContentGraphic3DType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .color:
                .basic
        case .gradient:
                .basic
        case .noise:
                .basic
        }
    }
}
