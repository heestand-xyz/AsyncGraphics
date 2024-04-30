import SwiftUI

@GraphicTypeMacro
public enum ConvertEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case resolution
    case bits
    case cornerPin
}

extension ConvertEffectGraphicType {
    
    public var symbolName: String {
        switch self {
        case .resolution:
            "square.resize"
        case .bits:
            "drop.keypad.rectangle"
        case .cornerPin:
            "skew"
        }
    }
}
