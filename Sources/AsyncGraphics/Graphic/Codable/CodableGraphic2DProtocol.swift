
public protocol CodableGraphic2DProtocol {
    var type: CodableGraphic2DType { get }
    var properties: [any AnyGraphicProperty] { get }
}
