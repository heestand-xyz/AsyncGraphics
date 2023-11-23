
public enum CodableGraphicType: Codable, Equatable {
    
    case content(ContentGraphicType)
    case effect(EffectGraphicType)
    
}

extension CodableGraphicType {
    
    public var name: String {
        switch self {
        case .content(let content):
            content.name
        case .effect(let effect):
            effect.name
        }
    }
}

extension CodableGraphicType: CaseIterable {
    
    public static var allCases: [CodableGraphicType] {
        ContentGraphicType.allCases.map { .content($0) } +
        EffectGraphicType.allCases.map { .effect($0) }
    }
}

extension CodableGraphicType {
    
    public var type: CodableGraphicProtocol.Type {
        switch self {
        case .content(let content):
            content.type
        case .effect(let effect):
            effect.type
        }
    }
    
    public func instance() -> CodableGraphicProtocol {
        type.init()
    }
}
