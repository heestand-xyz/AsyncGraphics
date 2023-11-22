
public protocol CodableGraphic3DProtocol {
    var type: CodableGraphic3DType { get }
    var properties: [any AnyGraphicProperty] { get }
    init()
}
