
public protocol CodableGraphic3DProtocol {
   
    static var type: CodableGraphic3DType { get }
    
    var properties: [any AnyGraphicProperty] { get }
        
    init()
    
    func isVisible(propertyKey: String, at resolution: SIMD3<Int>) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: SIMD3<Int>) -> Bool
    
    static func variants() -> [CodableGraphic3DVariant]
    static func variantIDs() -> [GraphicVariantID]
    func edit(variantKey: String)
    func edit<V: GraphicVariant>(variant: V)
}

extension CodableGraphic3DProtocol {
    
    var type: CodableGraphic3DType {
        Swift.type(of: self).type
    }
}

extension CodableGraphic3DProtocol {
    
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: SIMD3<Int>) -> Bool {
        true
    }
}


extension CodableGraphic3DProtocol {
    
    static func variants() -> [CodableGraphic3DVariant] {
        variantIDs().map { variantID in
            let instance: Self = .init()
            instance.edit(variantKey: variantID.key)
            return CodableGraphic3DVariant(
                description: variantID.description,
                instance: instance)
        }
    }
    
    func edit<V: GraphicVariant>(variant: V) {}
}
