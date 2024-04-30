
public enum CodableGraphic3DType: Codable, Equatable {
    
    case content(ContentGraphic3DType)
    case effect(EffectGraphic3DType)
    
}

extension CodableGraphic3DType {
    
    public var name: String {
        switch self {
        case .content(let content):
            content.name
        case .effect(let effect):
            effect.name
        }
    }
}

extension CodableGraphic3DType {
    
    public var symbolName: String {
        switch self {
        case .content(let content):
            content.symbolName
        case .effect(let effect):
            effect.symbolName
        }
    }
}

extension CodableGraphic3DType: CaseIterable {
    
    public static var allCases: [CodableGraphic3DType] {
        ContentGraphic3DType.allCases.map { .content($0) } +
        EffectGraphic3DType.allCases.map { .effect($0) }
    }
}

extension CodableGraphic3DType {
    
    public var type: CodableGraphic3DProtocol.Type {
        switch self {
        case .content(let content):
            content.type
        case .effect(let effect):
            effect.type
        }
    }
    
    public func instance() -> CodableGraphic3DProtocol {
        type.init()
    }
}
