import CoreGraphics

public protocol CodableGraphicProtocol {
    
    static var type: CodableGraphicType { get }
    
    var properties: [any AnyGraphicProperty] { get }
    
    init()
    
    func isVisible(propertyKey: String, at resolution: CGSize) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool
    
    associatedtype V: GraphicVariant
    static func variants() -> [CodableGraphicVariant]
    func edit(variant: V)
}

extension CodableGraphicProtocol {
    
    var type: CodableGraphicType {
        Swift.type(of: self).type
    }
}

extension CodableGraphicProtocol {
    
    static func variants() -> [CodableGraphicVariant] {
        V.allCases.map { variant in
            let instance = type.instance()
            instance.edit(variant: variant)
            return instance
        }
    }
}

extension CodableGraphicProtocol {
    
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool {
        true
    }
}
