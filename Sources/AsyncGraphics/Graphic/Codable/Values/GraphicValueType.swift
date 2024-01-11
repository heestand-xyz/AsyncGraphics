import Foundation
import SwiftUI
import Spatial
import PixelColor

public enum GraphicValueType: String, Codable, CaseIterable {
    case bool
    case int
    case double
    case angle
    case size
    case point
    case rect
    case color
    case point3D
    case size3D
    case gradient
}

extension GraphicValueType {
    
    public var graphicValueType: any GraphicValue.Type {
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
        case .size3D:
            return Size3D.self
        case .point3D:
            return Point3D.self
        case .gradient:
            return [Graphic.GradientStop].self
        }
    }
}
