import SwiftUI

@GraphicTypeMacro
public enum SpaceEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case blur
    case circleBlur
    case edge
    case transform
    case kaleidoscope
    case rainbowBlur
    case pixelate
    case sharpen
    case morph
}

extension SpaceEffectGraphicType {
    
    public var symbolName: String {
        switch self {
        case .blur:
            "aqi.medium"
        case .circleBlur:
            "circle.hexagongrid"
        case .edge:
            "square"
        case .transform:
            "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        case .kaleidoscope:
            "hexagon"
        case .rainbowBlur:
            "rainbow"
        case .pixelate:
            "squareshape.split.3x3"
        case .sharpen:
            "circle.lefthalf.filled"
        case .morph:
            "seal"
        }
    }
}

extension SpaceEffectGraphicType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .blur:
                .basic
        case .circleBlur:
                .basic
        case .edge:
                .basic
        case .transform:
                .basic
        case .kaleidoscope:
                .basic
        case .rainbowBlur:
                .basic
        case .pixelate:
                .basic
        case .sharpen:
                .advanced
        case .morph:
                .advanced
        }
    }
}
