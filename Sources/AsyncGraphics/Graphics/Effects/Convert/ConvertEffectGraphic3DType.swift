import SwiftUI

@GraphicTypeMacro
public enum ConvertEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case bits
    case crop
}

extension ConvertEffectGraphic3DType {
    
    public var symbolName: String {
        switch self {
        case .bits:
            "drop.keypad.rectangle"
        case .crop:
            "crop"
        }
    }
}

extension ConvertEffectGraphic3DType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .bits:
                .advanced
        case .crop:
                .basic
        }
    }
}
