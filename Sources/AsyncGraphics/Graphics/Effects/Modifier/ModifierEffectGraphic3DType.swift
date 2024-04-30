import SwiftUI

@GraphicTypeMacro
public enum ModifierEffectGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case mask
    case cross
    case blend
    case displace
    case lookup
    case lumaLevels
    case lumaColorShift
    case lumaBlur
    case lumaRainbowBlur
    case lumaTransform
}

extension ModifierEffectGraphic3DType {
    
    var symbolName: String {
        switch self {
        case .mask:
            "circle.rectangle.dashed"
        case .cross:
            "arrow.triangle.merge"
        case .blend:
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
