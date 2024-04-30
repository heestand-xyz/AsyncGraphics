
public enum EffectGraphicType: Codable, Equatable {
    
    case color(ColorEffectGraphicType)
    case space(SpaceEffectGraphicType)
    case modifier(ModifierEffectGraphicType)
    case convert(ConvertEffectGraphicType)
}

extension EffectGraphicType {
    
    public var name: String {
        switch self {
        case .color(let color):
            color.name
        case .space(let space):
            space.name
        case .modifier(let modifier):
            modifier.name
        case .convert(let convert):
            convert.name
        }
    }
}

extension EffectGraphicType {
    
    public var symbolName: String {
        switch self {
        case .color(let color):
            color.symbolName
        case .space(let space):
            space.symbolName
        case .modifier(let modifier):
            modifier.symbolName
        case .convert(let convert):
            convert.symbolName
        }
    }
}

extension EffectGraphicType: CaseIterable {
    
    public static var allCases: [EffectGraphicType] {
        ColorEffectGraphicType.allCases.map { .color($0) }
        + SpaceEffectGraphicType.allCases.map { .space($0) }
        + ModifierEffectGraphicType.allCases.map { .modifier($0) }
        + ConvertEffectGraphicType.allCases.map { .convert($0) }
    }
}

extension EffectGraphicType {
    
    public var type: EffectGraphicProtocol.Type {
        switch self {
        case .color(let color):
            color.type
        case .space(let space):
            space.type
        case .modifier(let modifier):
            modifier.type
        case .convert(let convert):
            convert.type
        }
    }
}
