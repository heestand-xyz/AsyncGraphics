import SwiftUI

@GraphicTypeMacro
public enum SolidContentGraphicType: String, CodableGraphicTypeProtocol {
    
    case color
    case gradient
    case noise
}

extension SolidContentGraphicType {
    
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
