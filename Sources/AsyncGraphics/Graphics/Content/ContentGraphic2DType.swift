
public enum ContentGraphic2DType: Codable, Equatable {
    
    case shape(ShapeGraphic2DType)
    case solid(SolidGraphic2DType)
}

extension ContentGraphic2DType: CaseIterable {
    
    public static var allCases: [ContentGraphic2DType] {
        ShapeGraphic2DType.allCases.map { .shape($0) } +
        SolidGraphic2DType.allCases.map { .solid($0) }
    }
}

extension ContentGraphic2DType {
    
    public func instance() -> ContentGraphic2DProtocol {
        switch self {
        case .shape(let type):
            type.instance()
        case .solid(let type):
            type.instance()
        }
    }
}
