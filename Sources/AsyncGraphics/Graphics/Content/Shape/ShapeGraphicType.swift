import SwiftUI

public enum ShapeGraphicType: String, Codable, Equatable, CaseIterable {
    
    case circle
    case rectangle
    case polygon
    case star
    case arc
    case line
}

extension ShapeGraphicType: Identifiable {
    
    public var id: String {
        rawValue
    }
}

extension ShapeGraphicType {
    
    public var type: ShapeGraphicProtocol.Type {
        switch self {
        case .circle:
            CodableGraphic.Content.Shape.Circle.self
        case .rectangle:
            CodableGraphic.Content.Shape.Rectangle.self
        case .polygon:
            CodableGraphic.Content.Shape.Polygon.self
        case .star:
            CodableGraphic.Content.Shape.Star.self
        case .arc:
            CodableGraphic.Content.Shape.Arc.self
        case .line:
            CodableGraphic.Content.Shape.Line.self
        }
    }
}
