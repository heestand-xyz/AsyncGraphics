import SwiftUI

@GraphicTypeMacro
public enum ColorEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case channelMix
    case clamp
    case colorMap
    case colorShift
    case gradientLookup
    case levels
    case quantize
    case slope
    case threshold
}

extension ColorEffectGraphic3DType {
    
    var symbolName: String {
        switch self {
        case .channelMix:
            "square.stack.3d.forward.dottedline"
        case .clamp:
            "rectangle.compress.vertical"
        case .colorMap:
            "circle.lefthalf.filled.righthalf.striped.horizontal.inverse"
        case .colorShift:
            "arrow.triangle.2.circlepath.circle"
        case .gradientLookup:
            "circle.and.line.horizontal"
        case .levels:
            "slider.horizontal.3"
        case .quantize:
            "righttriangle.split.diagonal"
        case .slope:
            "righttriangle"
        case .threshold:
            "circle.lefthalf.filled"
        }
    }
}
