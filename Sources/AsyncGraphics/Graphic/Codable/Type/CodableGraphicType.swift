
public enum CodableGraphicType: Codable, Equatable {
    
    case content(ContentGraphicType)
    
}

extension CodableGraphicType: CaseIterable {
    
    public static var allCases: [CodableGraphicType] {
        ContentGraphicType.allCases.map { .content($0) }
    }
}

extension CodableGraphicType {
    
    public var type: CodableGraphicProtocol.Type {
        switch self {
        case .content(let content):
            content.type
        }
    }
    
    public func instance() -> CodableGraphicProtocol {
        type.init()
    }
}
