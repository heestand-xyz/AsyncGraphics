
public protocol CodableGraphicProtocol {
    var type: CodableGraphicType { get }
    var properties: [any AnyGraphicProperty] { get }
}
