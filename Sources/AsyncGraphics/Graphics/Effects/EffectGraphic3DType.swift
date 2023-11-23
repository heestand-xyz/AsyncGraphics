
public enum EffectGraphic3DType: Codable, Equatable {
    
    case direct(DirectEffectGraphic3DType)
}

extension EffectGraphic3DType {
    
    public var name: String {
        switch self {
        case .direct(let direct):
            direct.name
        }
    }
}

extension EffectGraphic3DType: CaseIterable {
    
    public static var allCases: [EffectGraphic3DType] {
        DirectEffectGraphic3DType.allCases.map { .direct($0) }
    }
}

extension EffectGraphic3DType {
    
    public var type: EffectGraphic3DProtocol.Type {
        switch self {
        case .direct(let direct):
            direct.type
        }
    }
}
