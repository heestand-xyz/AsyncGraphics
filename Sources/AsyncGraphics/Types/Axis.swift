//
//  Created by Anton Heestand on 2022-04-11.
//

import TextureMap

public enum Axis {
    case x
    case y
    case z
}

extension Axis {
    
    var index: Int {
        switch self {
        case .x:
            return 0
        case .y:
            return 1
        case .z:
            return 2
        }
    }
}

extension Axis {
    
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
