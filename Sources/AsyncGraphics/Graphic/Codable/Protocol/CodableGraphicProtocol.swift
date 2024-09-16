import CoreGraphics

public protocol CodableGraphicProtocol {
    
    static var type: CodableGraphicType { get }
    
    var docs: String { get }
    var tags: [String] { get }
    
    var properties: [any AnyGraphicProperty] { get }
    
    init()
    
    func isVisible(propertyKey: String, at resolution: CGSize) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool
    
    static func variants() -> [CodableGraphicVariant]
    static func variantIDs() -> [GraphicVariantID]
    func edit(variantKey: String)
    func edit<V: GraphicVariant>(variant: V)
}

extension CodableGraphicProtocol {
    
    public var type: CodableGraphicType {
        Swift.type(of: self).type
    }
}

extension CodableGraphicProtocol {
    
    public var docs: String { "" }
    public var tags: [String] { [] }
}

extension CodableGraphicProtocol {
    
    public func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool {
        true
    }
}


extension CodableGraphicProtocol {
    
    public static func variants() -> [CodableGraphicVariant] {
        variantIDs().map { variantID in
            let instance: Self = .init()
            instance.edit(variantKey: variantID.key)
            return CodableGraphicVariant(
                description: variantID.description,
                instance: instance)
        }
    }
    
    public func edit<V: GraphicVariant>(variant: V) {}
}
