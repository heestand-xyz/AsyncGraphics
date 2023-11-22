
public enum CodableGraphic2DType: Codable, Equatable {
    
    case content(ContentGraphic2DType)
    
}

extension CodableGraphic2DType: CaseIterable {
    
    public static var allCases: [CodableGraphic2DType] {
        ContentGraphic2DType.allCases.map { .content($0) }
    }
}

extension CodableGraphic2DType {
    
    public func instance() -> CodableGraphic2DProtocol {
        switch self {
        case .content(let type):
            type.instance()
        }
    }
}
