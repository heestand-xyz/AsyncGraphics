
public enum EffectGraphic3DType: Codable, Equatable {
    
    case color(ColorEffectGraphic3DType)
    case space(SpaceEffectGraphic3DType)
    case modifier(ModifierEffectGraphic3DType)
    case convert(ConvertEffectGraphic3DType)
}

extension EffectGraphic3DType {
    
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

extension EffectGraphic3DType {
    
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

extension EffectGraphic3DType: CaseIterable {
    
    public static var allCases: [EffectGraphic3DType] {
        ColorEffectGraphic3DType.allCases.map { .color($0) }
        + SpaceEffectGraphic3DType.allCases.map { .space($0) }
        + ModifierEffectGraphic3DType.allCases.map { .modifier($0) }
        + ConvertEffectGraphic3DType.allCases.map { .convert($0) }
    }
}

extension EffectGraphic3DType {
    
    public var type: EffectGraphic3DProtocol.Type {
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
