
public enum EffectGraphicType: Codable, Equatable {
    
    case direct(DirectEffectGraphicType)
}

extension EffectGraphicType {
    
    public var name: String {
        switch self {
        case .direct(let direct):
            direct.name
        }
    }
}

extension EffectGraphicType: CaseIterable {
    
    public static var allCases: [EffectGraphicType] {
        DirectEffectGraphicType.allCases.map { .direct($0) }
    }
}

extension EffectGraphicType {
    
    public var type: EffectGraphicProtocol.Type {
        switch self {
        case .direct(let direct):
            direct.type
        }
    }
}
