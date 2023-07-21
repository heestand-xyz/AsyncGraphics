//
//  Created by Anton Heestand on 2022-04-03.
//

public enum Placement: String, Codable, CaseIterable, Identifiable {
    
    case fit
    case fill
    case fixed
    case stretch
    
    @available(*, deprecated, renamed: "fixed")
    public static let center: Placement = .fixed
    
    public var id: String {
        rawValue
    }
    
    var index: UInt32 {
        switch self {
        case .stretch: return 0
        case .fit: return 1
        case .fill: return 2
        case .fixed: return 3
        }
    }
    
    @available(*, deprecated)
    public var name: String {
        switch self {
        case .fit:
            return "Fit"
        case .fill:
            return "Fill"
        case .fixed:
            return "Fixed"
        case .stretch:
            return "Stretch"
        }
    }
}
