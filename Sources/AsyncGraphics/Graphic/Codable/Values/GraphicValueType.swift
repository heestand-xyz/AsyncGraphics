import Foundation
import SwiftUI
import simd
import PixelColor

public enum GraphicValueType {
    case bool
    case int
    case double
    case angle
    case size
    case point
    case rect
    case color
    case intVector
    case doubleVector
    case gradient
}

extension GraphicValueType {
    var graphicValueType: any GraphicValue.Type {
        switch self {
        case .bool:
            return Bool.self
        case .int:
            return Int.self
        case .double:
            return Double.self
        case .angle:
            return Angle.self
        case .size:
            return CGSize.self
        case .point:
            return CGPoint.self
        case .rect:
            return CGRect.self
        case .color:
            return PixelColor.self
        case .intVector:
            return SIMD3<Int>.self
        case .doubleVector:
            return SIMD3<Double>.self
        case .gradient:
            return [Graphic.GradientStop].self
        }
    }
}
