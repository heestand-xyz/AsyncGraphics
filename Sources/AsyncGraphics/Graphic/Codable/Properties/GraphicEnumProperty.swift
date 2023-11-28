import Foundation
import Spatial
import PixelColor

@propertyWrapper
public class GraphicEnumProperty<T: GraphicEnum> where T.RawValue == String {
    
    public let key: String
    public let name: String
    
    public var wrappedValue: GraphicEnumMetadata<T>
    
    public var allCases: [GraphicEnumCase] {
        T.allCases.map { enumCase in
            GraphicEnumCase(rawValue: enumCase.rawValue, name: enumCase.name)
        }
    }
    
    public init(
        wrappedValue: GraphicEnumMetadata<T>,
        key: String,
        name: String
    ) {
        self.key = key
        self.name = name
        self.wrappedValue = wrappedValue
    }
}

extension GraphicEnumProperty {

    public func erase() -> AnyGraphicEnumProperty {
        AnyGraphicEnumProperty(
            key: key,
            name: name,
            value: wrappedValue.value,
            defaultValue: wrappedValue.defaultValue,
            allCases: allCases
        ) { [weak self] value in
            self?.wrappedValue.value = value
        }
    }
}
