import CoreGraphics

public struct GraphicEnumMetadata<T: GraphicEnum>: Codable, Sendable where T.RawValue == String {
    
    public var value: T
    public var defaultValue: T
    public let docs: String
    
    init(value: T, docs: String = "") {
        self.value = value
        defaultValue = value
        self.docs = docs
    }
}
