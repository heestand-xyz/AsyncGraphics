import CoreGraphics

public struct GraphicEnumMetadata<T: GraphicEnum>: Codable where T.RawValue == String {
    
    public var value: T
    public var defaultValue: T
    
    init(value: T) {
        self.value = value
        defaultValue = value
    }
}
