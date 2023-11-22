
public protocol CodableGraphic3DProtocol {
   
    var type: CodableGraphic3DType { get }
    
    var properties: [any AnyGraphicProperty] { get }
        
    init()
    
    func isVisible(propertyKey: String, at resolution: SIMD3<Int>) -> Bool?
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: SIMD3<Int>) -> Bool
}

extension CodableGraphic3DProtocol {
    
    func isVisible<P: GraphicPropertyType>(property: P, at resolution: SIMD3<Int>) -> Bool {
        true
    }
}
