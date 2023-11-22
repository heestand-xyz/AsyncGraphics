import SwiftUI

@GraphicTypeMacro
public enum SolidContentGraphic3DType: String, CodableGraphicTypeProtocol {
    
    case color
    case gradient
    case noise
}

//extension SolidContentGraphic3DType {
//    
//    public var type: SolidContentGraphic3DProtocol.Type {
//        switch self {
//        case .color:
//            CodableGraphic3D.Content.Solid.Color.self
//        case .gradient:
//            CodableGraphic3D.Content.Solid.Gradient.self
//        case .noise:
//            CodableGraphic3D.Content.Solid.Noise.self
//        }
//    }
//}
