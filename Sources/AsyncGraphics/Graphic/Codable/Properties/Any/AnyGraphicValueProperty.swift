import Foundation
import SwiftUI

public class AnyGraphicValueProperty: AnyGraphicProperty {
    
    public let type: GraphicValueType
    
    public let key: String
    public let name: String
    
    public let value: String
    public let defaultValue: String
    public let minimumValue: String
    public let maximumValue: String
    
    public let options: GraphicMetadataOptions
    
    private var updateValue: (String) throws -> ()
    
    init<T: GraphicValue>(type: GraphicValueType,
                          key: String,
                          name: String,
                          value: GraphicMetadataValue<T>,
                          defaultValue: GraphicMetadataValue<T>,
                          minimumValue: GraphicMetadataValue<T>,
                          maximumValue: GraphicMetadataValue<T>,
                          options: GraphicMetadataOptions,
                          update: @escaping (GraphicMetadataValue<T>) -> ()) {
        
        self.type = type
        
        self.key = key
        self.name = name
        
        self.value = Self.encode(value)
        self.defaultValue = Self.encode(defaultValue)
        self.minimumValue = Self.encode(minimumValue)
        self.maximumValue = Self.encode(maximumValue)
        
        self.options = options
        
        updateValue = { string in
            try update(Self.decode(string))
        }
    }
}

public extension AnyGraphicValueProperty {
    
    func getValue<T: GraphicValue>() throws -> GraphicMetadataValue<T> {
        try Self.decode(value)
    }
    
    func getDefaultValue<T: GraphicValue>() throws -> GraphicMetadataValue<T> {
        try Self.decode(defaultValue)
    }
    
    func getMinimumValue<T: GraphicValue>() throws -> GraphicMetadataValue<T> {
        try Self.decode(minimumValue)
    }
    
    func getMaximumValue<T: GraphicValue>() throws -> GraphicMetadataValue<T> {
        try Self.decode(maximumValue)
    }
    
    func setValue<T: GraphicValue>(_ value: GraphicMetadataValue<T>) throws {
        try updateValue(Self.encode(value))
    }
    
    func setEncodedValue(_ encodedValue: String) throws {
        try updateValue(encodedValue)
    }
}

extension AnyGraphicValueProperty {
    
    static func encode<T: GraphicValue>(_ value: GraphicMetadataValue<T>) -> String {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8)!
        } catch {
            fatalError("CodableGraphics - Encode in Property Failed: \(error)")
        }
    }
    
    static func decode<T: GraphicValue>(_ string: String) throws -> GraphicMetadataValue<T> {
        let decoder = JSONDecoder()
        let data: Data = string.data(using: .utf8)!
        return try decoder.decode(GraphicMetadataValue<T>.self, from: data)
    }
}
