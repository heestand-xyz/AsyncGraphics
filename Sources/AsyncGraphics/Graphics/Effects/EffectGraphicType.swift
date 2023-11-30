
public enum EffectGraphicType: Codable, Equatable {
    
    case color(ColorEffectGraphicType)
    case space(SpaceEffectGraphicType)
}

extension EffectGraphicType {
    
    public var name: String {
        switch self {
        case .color(let color):
            color.name
        case .space(let space):
            space.name
        }
    }
}

extension EffectGraphicType: CaseIterable {
    
    public static var allCases: [EffectGraphicType] {
        ColorEffectGraphicType.allCases.map { .color($0) } +
        SpaceEffectGraphicType.allCases.map { .space($0) }
    }
}

extension EffectGraphicType {
    
    public var type: EffectGraphicProtocol.Type {
        switch self {
        case .color(let color):
            color.type
        case .space(let space):
            space.type
        }
    }
}
