import Foundation
import SwiftUI
import simd
import PixelColor

@propertyWrapper
public class GraphicValueProperty<T: GraphicValue> {
    
    public let key: String
    public let name: String
    
    public var wrappedValue: GraphicMetadata<T>
    
    public init(
        wrappedValue: GraphicMetadata<T>,
        key: String,
        name: String
    ) {
        self.key = key
        self.name = name
        self.wrappedValue = wrappedValue
    }
}

extension GraphicValueProperty {

    public func erase() -> AnyGraphicValueProperty {
        AnyGraphicValueProperty(
            type: type,
            key: key,
            name: name,
            value: wrappedValue.value,
            defaultValue: wrappedValue.defaultValue,
            minimumValue: wrappedValue.minimumValue,
            maximumValue: wrappedValue.maximumValue
        ) { [weak self] value in
            self?.wrappedValue.value = value
        }
    }
}

extension GraphicValueProperty {
    
    public var type: GraphicValueType {
        switch T.self {
        case is Bool.Type:
            return .bool
        case is Int.Type:
            return .int
        case is Double.Type, is CGFloat.Type:
            return .double
        case is Angle.Type:
            return .angle
        case is PixelColor.Type:
            return .color
        case is CGSize.Type:
            return .size
        case is CGPoint.Type:
            return .point
        case is CGRect.Type:
            return .rect
        case is SIMD3<Int>.Type:
            return .intVector
        case is SIMD3<Double>.Type:
            return .doubleVector
        case is [Graphic.GradientStop].Type:
            return .gradient
        default:
            fatalError("Unsupported Graphic Property Type (\(T.self))")
        }
    }
}
