import SwiftUI

@GraphicTypeMacro
public enum ModifierEffectGraphicType: String, CodableGraphicTypeProtocol {
    
    case mask
    case cross
    case blend
    case frameBlend
    case transformBlend
    case displace
    case lookup
    case lumaLevels
    case lumaColorShift
    case lumaBlur
    case lumaRainbowBlur
    case lumaTransform
}

extension ModifierEffectGraphicType {
    
    public var symbolName: String {
        switch self {
        case .mask:
            "circle.rectangle.dashed"
        case .cross:
            "arrow.triangle.merge"
        case .blend, .frameBlend, .transformBlend:
            "camera.filters"
        case .displace:
            "circle.dotted.and.circle"
        case .lookup:
            "eye"
        case .lumaLevels:
            "slider.horizontal.3"
        case .lumaColorShift:
            "arrow.triangle.2.circlepath.circle"
        case .lumaBlur:
            "aqi.medium"
        case .lumaRainbowBlur:
            "rainbow"
        case .lumaTransform:
            "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        }
    }
}

extension ModifierEffectGraphicType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .mask:
                .basic
        case .cross:
                .basic
        case .blend:
                .basic
        case .frameBlend:
                .advanced
        case .transformBlend:
                .advanced
        case .displace:
                .basic
        case .lookup:
                .advanced
        case .lumaLevels:
                .advanced
        case .lumaColorShift:
                .advanced
        case .lumaBlur:
                .advanced
        case .lumaRainbowBlur:
                .advanced
        case .lumaTransform:
                .advanced
        }
    }
}
