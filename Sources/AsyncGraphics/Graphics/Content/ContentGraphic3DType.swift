
public enum ContentGraphic3DType: Codable, Equatable {
    
    case shape(ShapeContentGraphic3DType)
    case solid(SolidContentGraphic3DType)
}

extension ContentGraphic3DType {
    
    public var name: String {
        switch self {
        case .shape(let shape):
            shape.name
        case .solid(let solid):
            solid.name
        }
    }
}

extension ContentGraphic3DType: CaseIterable {
    
    public static var allCases: [ContentGraphic3DType] {
        ShapeContentGraphic3DType.allCases.map { .shape($0) } +
        SolidContentGraphic3DType.allCases.map { .solid($0) }
    }
}

extension ContentGraphic3DType {
    
    public var type: ContentGraphic3DProtocol.Type {
        switch self {
        case .shape(let shape):
            shape.type
        case .solid(let solid):
            solid.type
        }
    }
}
