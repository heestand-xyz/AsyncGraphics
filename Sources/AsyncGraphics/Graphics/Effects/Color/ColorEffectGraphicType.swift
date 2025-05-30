import SwiftUI

@GraphicTypeMacro
public enum ColorEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case channelMix
    case chromaKey
    case range
    case clamp
    case colorConvert
    case colorMap
    case colorShift
    case gradientLookup
    case levels
    case quantize
    case personSegmentation
    case saliency
    case slope
    case threshold
}

extension ColorEffectGraphicType {
    
    public var symbolName: String {
        switch self {
        case .channelMix:
            "square.stack.3d.forward.dottedline"
        case .chromaKey:
            "rectangle.checkered"
        case .range:
            "rectangle.compress.vertical"
        case .clamp:
            "rectangle.compress.vertical"
        case .colorConvert:
            "ev.plug.ac.type.1"
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
        case .personSegmentation:
            "person.and.background.dotted"
        case .saliency:
            "allergens"
        case .slope:
            "righttriangle"
        case .threshold:
            "circle.lefthalf.filled"
        }
    }
}

extension ColorEffectGraphicType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .channelMix:
                .advanced
        case .chromaKey:
                .basic
        case .range:
                .advanced
        case .clamp:
                .advanced
        case .colorConvert:
                .advanced
        case .colorMap:
                .basic
        case .colorShift:
                .basic
        case .gradientLookup:
                .basic
        case .levels:
                .basic
        case .quantize:
                .basic
        case .personSegmentation:
                .basic
        case .saliency:
                .advanced
        case .slope:
                .advanced
        case .threshold:
                .basic
        }
    }
}
