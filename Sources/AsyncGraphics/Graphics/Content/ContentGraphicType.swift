
public enum ContentGraphicType: Codable, Equatable {
    
    case shape(ShapeGraphicType)
    case solid(SolidGraphicType)
}

extension ContentGraphicType: CaseIterable {
    
    public static var allCases: [ContentGraphicType] {
        ShapeGraphicType.allCases.map { .shape($0) } +
        SolidGraphicType.allCases.map { .solid($0) }
    }
}

extension ContentGraphicType {
    
    public func instance() -> ContentGraphicProtocol {
        switch self {
        case .shape(let type):
            type.instance()
        case .solid(let type):
            type.instance()
        }
    }
}
