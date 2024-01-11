import CoreGraphics

public struct GraphicMetadata<T: GraphicValue>: Codable {
    
    public var value: GraphicMetadataValue<T>
    public var defaultValue: GraphicMetadataValue<T>
    
    public let minimumValue: GraphicMetadataValue<T>
    public let maximumValue: GraphicMetadataValue<T>
    
    let options: GraphicMetadataOptions
    
    public init(value: GraphicMetadataValue<T> = T.default,
                minimum: GraphicMetadataValue<T> = T.minimum,
                maximum: GraphicMetadataValue<T> = T.maximum,
                options: GraphicMetadataOptions = []) {
        self.value = value
        defaultValue = value
        minimumValue = minimum
        maximumValue = maximum
        self.options = options
    }
}
