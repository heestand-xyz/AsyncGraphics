
public enum ContentGraphicType: Codable, Equatable {
    
    case shape(ShapeContentGraphicType)
    case solid(SolidContentGraphicType)
}

extension ContentGraphicType {
    
    public var name: String {
        switch self {
        case .shape(let shape):
            shape.name
        case .solid(let solid):
            solid.name
        }
    }
}

extension ContentGraphicType {
    
    public var symbolName: String {
        switch self {
        case .shape(let shape):
            shape.symbolName
        case .solid(let solid):
            solid.symbolName
        }
    }
}

extension ContentGraphicType {
    
    public var complexity: GraphicComplexity {
        switch self {
        case .shape(let shape):
            shape.complexity
        case .solid(let solid):
            solid.complexity
        }
    }
}

extension ContentGraphicType: CaseIterable {
    
    public static var allCases: [ContentGraphicType] {
        ShapeContentGraphicType.allCases.map { .shape($0) } +
        SolidContentGraphicType.allCases.map { .solid($0) }
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
