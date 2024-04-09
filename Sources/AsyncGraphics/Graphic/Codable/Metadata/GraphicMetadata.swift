import CoreGraphics

public struct GraphicMetadata<T: GraphicValue>: Codable {
    
    public var value: GraphicMetadataValue<T>
    public var defaultValue: GraphicMetadataValue<T>
    
    public let minimumValue: GraphicMetadataValue<T>
    public let maximumValue: GraphicMetadataValue<T>
    
    public let options: GraphicMetadataOptions
    
    public let docs: String
    
    public init(value: GraphicMetadataValue<T> = T.default,
                minimum: GraphicMetadataValue<T> = T.minimum,
                maximum: GraphicMetadataValue<T> = T.maximum,
                options: GraphicMetadataOptions = [],
                docs: String = "") {
        self.value = value
        defaultValue = value
        minimumValue = minimum
        maximumValue = maximum
        self.options = options
        self.docs = docs
    }
}
