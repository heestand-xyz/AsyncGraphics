//
//  Created by Anton Heestand on 2022-04-03.
//

public enum Placement {
    
    case fit
    case fill
    case center
    case stretch
    
    var index: Int {
        switch self {
        case .stretch: return 0
        case .fit: return 1
        case .fill: return 2
        case .center: return 3
        }
    }
}
