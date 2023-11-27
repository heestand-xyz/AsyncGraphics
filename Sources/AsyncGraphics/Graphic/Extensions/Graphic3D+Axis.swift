//
//  Created by Anton Heestand on 2022-04-11.
//

import TextureMap

extension Graphic3D {
    
    @EnumMacro
    public enum Axis: String, GraphicEnum {
        case x
        case y
        case z
    }
}

extension Graphic3D.Axis {
    
    var tmAxis: TMAxis {
        switch self {
        case .x:
            return .x
        case .y:
            return .y
        case .z:
            return .z
        }
    }
}
