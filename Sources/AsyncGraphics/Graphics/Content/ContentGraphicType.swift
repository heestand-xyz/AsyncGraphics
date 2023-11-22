
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
    
    public var type: ContentGraphicProtocol.Type {
        switch self {
        case .shape(let shape):
            shape.type
        case .solid(let solid):
            solid.type
        }
    }
}
