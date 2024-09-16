import Spatial

public protocol CodableGraphic3DProtocol {
   
    static var type: CodableGraphic3DType { get }
    
    var docs: String { get }
    var tags: [String] { get }
    
    var properties: [any AnyGraphicProperty] { get }
        
    init()
    
    func isVisible(propertyKey: String, at resolution: Size3D) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: Size3D) -> Bool
    
    static func variants() -> [CodableGraphic3DVariant]
    static func variantIDs() -> [GraphicVariantID]
    func edit(variantKey: String)
    func edit<V: GraphicVariant>(variant: V)
}

extension CodableGraphic3DProtocol {
    
    public var type: CodableGraphic3DType {
        Swift.type(of: self).type
    }
}

extension CodableGraphic3DProtocol {
    
    public var docs: String { "" }
    public var tags: [String] { [] }
}

extension CodableGraphic3DProtocol {
    
    public func isVisible<P: GraphicPropertyType>(property: P, at resolution: Size3D) -> Bool {
        true
    }
}


extension CodableGraphic3DProtocol {
    
    public static func variants() -> [CodableGraphic3DVariant] {
        variantIDs().map { variantID in
            let instance: Self = .init()
            instance.edit(variantKey: variantID.key)
            return CodableGraphic3DVariant(
                description: variantID.description,
                instance: instance)
        }
    }
    
    public func edit<V: GraphicVariant>(variant: V) {}
}
