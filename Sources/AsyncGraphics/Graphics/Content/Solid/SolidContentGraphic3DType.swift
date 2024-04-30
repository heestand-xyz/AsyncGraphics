import SwiftUI

@GraphicTypeMacro
public enum SolidContentGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case color
    case gradient
    case noise
}

extension SolidContentGraphic3DType {
    
    var symbolName: String {
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
