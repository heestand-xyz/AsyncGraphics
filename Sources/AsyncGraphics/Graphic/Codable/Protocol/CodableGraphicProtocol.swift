import CoreGraphics

public protocol CodableGraphicProtocol {
    
    var type: CodableGraphicType { get }
    
    var properties: [any AnyGraphicProperty] { get }
    
    init()
    
    func isVisible(propertyKey: String, at resolution: CGSize) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool
}

extension CodableGraphicProtocol {
    
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: CGSize) -> Bool {
        true
    }
}
