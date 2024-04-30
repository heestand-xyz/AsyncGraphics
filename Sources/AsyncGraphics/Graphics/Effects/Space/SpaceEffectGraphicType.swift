import SwiftUI

@GraphicTypeMacro
public enum SpaceEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case blur
    case circleBlur
    case edge
    case transform
}

extension SpaceEffectGraphicType {
    
    var symbolName: String {
        switch self {
        case .blur:
            "aqi.medium"
        case .circleBlur:
            "circle.hexagongrid"
        case .edge:
            "square"
        case .transform:
            "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        }
    }
}
