import SwiftUI

@GraphicTypeMacro
public enum ConvertEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case bits
}

extension ConvertEffectGraphic3DType {
    
    public var symbolName: String {
        switch self {
        case .bits:
            "drop.keypad.rectangle"
        }
    }
}
