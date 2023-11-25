import CoreGraphics

public protocol CodableGraphicProtocol {
    
    static var type: CodableGraphicType { get }
    
    var properties: [any AnyGraphicProperty] { get }
    
    init()
    
    func isVisible(propertyKey: String, at resolution: CGSize) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool
    
    static func variants() -> [Self]
    static func variantKeys() -> [String]
    func edit(variantKey: String)
    func edit<V: GraphicVariant>(variant: V)
}

extension CodableGraphicProtocol {
    
    var type: CodableGraphicType {
        Swift.type(of: self).type
    }
}

extension CodableGraphicProtocol {
    
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool {
        true
    }
}


extension CodableGraphicProtocol {
    
    static func variants() -> [Self] {
        variantKeys().map { variantKey in
            let instance: Self = .init()
            instance.edit(variantKey: variantKey)
            return instance
        }
    }
    
    func edit<V: GraphicVariant>(variant: V) {}
}
