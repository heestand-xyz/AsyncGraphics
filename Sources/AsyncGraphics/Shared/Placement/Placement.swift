//
//  Created by Anton Heestand on 2022-04-03.
//

public enum Placement: String, Codable, CaseIterable, Identifiable {
    
    case fit
    case fill
    case center
    case stretch
    
    public var id: String {
        rawValue
    }
    
    var index: UInt32 {
        switch self {
        case .stretch: return 0
        case .fit: return 1
        case .fill: return 2
        case .center: return 3
        }
    }
    
    public var name: String {
        switch self {
        case .fit:
            return "Fit"
        case .fill:
            return "Fill"
        case .center:
            return "Center"
        case .stretch:
            return "Stretch"
        }
    }
}
