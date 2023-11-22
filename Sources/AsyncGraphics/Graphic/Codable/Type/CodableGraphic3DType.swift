
public enum CodableGraphic3DType: Codable, Equatable {
    
    case content(ContentGraphic3DType)
    
}

extension CodableGraphic3DType: CaseIterable {
    
    public static var allCases: [CodableGraphic3DType] {
        ContentGraphic3DType.allCases.map { .content($0) }
    }
}

extension CodableGraphic3DType {
    
    public var type: CodableGraphic3DProtocol.Type {
        switch self {
        case .content(let content):
            content.type
        }
    }
    
    public func instance() -> CodableGraphic3DProtocol {
        type.init()
    }
}
