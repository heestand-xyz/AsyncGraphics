
public enum ContentGraphic3DType: Codable, Equatable {
    
    case shape(ShapeGraphic3DType)
    case solid(SolidGraphic3DType)
}

extension ContentGraphic3DType: CaseIterable {
    
    public static var allCases: [ContentGraphic3DType] {
        ShapeGraphic3DType.allCases.map { .shape($0) } +
        SolidGraphic3DType.allCases.map { .solid($0) }
    }
}

extension ContentGraphic3DType {
    
    public func instance() -> ContentGraphic3DProtocol {
        switch self {
        case .shape(let type):
            type.instance()
        case .solid(let type):
            type.instance()
        }
    }
}
