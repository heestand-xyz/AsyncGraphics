import Foundation
import SwiftUI

public class AnyGraphicValueProperty: AnyGraphicProperty {
    
    public let type: GraphicValueType
    
    public let key: String
    public let name: String
    
    private let value: String
    private let defaultValue: String
    private let minimumValue: String
    private let maximumValue: String
    
    private var updateValue: (String) -> ()
    
    init<T: GraphicValue>(type: GraphicValueType,
                          key: String,
                          name: String,
                          value: GraphicMetadataValue<T>,
                          defaultValue: GraphicMetadataValue<T>,
                          minimumValue: GraphicMetadataValue<T>,
                          maximumValue: GraphicMetadataValue<T>,
                          update: @escaping (GraphicMetadataValue<T>) -> ()) {
        
        self.type = type
        
        self.key = key
        self.name = name
        
        self.value = Self.encode(value)
        self.defaultValue = Self.encode(defaultValue)
        self.minimumValue = Self.encode(minimumValue)
        self.maximumValue = Self.encode(maximumValue)
        
        updateValue = { string in
            update(Self.decode(string))
        }
    }
}

public extension AnyGraphicValueProperty {
    
    func getValue<T: GraphicValue>() -> GraphicMetadataValue<T> {
        Self.decode(value)
    }
    
    func getDefaultValue<T: GraphicValue>() -> GraphicMetadataValue<T> {
        Self.decode(defaultValue)
    }
    
    func getMiniumValue<T: GraphicValue>() -> GraphicMetadataValue<T> {
        Self.decode(minimumValue)
    }
    
    func getMaximumValue<T: GraphicValue>() -> GraphicMetadataValue<T> {
        Self.decode(maximumValue)
    }
    
    func setValue<T: GraphicValue>(_ value: GraphicMetadataValue<T>) {
        updateValue(Self.encode(value))
    }
}

extension AnyGraphicValueProperty {
    
    static func encode<T: GraphicValue>(_ value: GraphicMetadataValue<T>) -> String {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8)!
        } catch {
            fatalError("CodableGraphics - Encode in Property Failed: \(error.localizedDescription)")
        }
    }
    
    static func decode<T: GraphicValue>(_ string: String) -> GraphicMetadataValue<T> {
        do {
            let decoder = JSONDecoder()
            let data: Data = string.data(using: .utf8)!
            return try decoder.decode(GraphicMetadataValue<T>.self, from: data)
        } catch {
            fatalError("CodableGraphics - Decode in Property Failed: \(error.localizedDescription)")
        }
    }
}
