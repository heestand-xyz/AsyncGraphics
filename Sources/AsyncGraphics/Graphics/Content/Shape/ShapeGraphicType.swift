import SwiftUI

public enum ShapeGraphicType: String, Codable, Equatable, CaseIterable {
    
    case circle
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
        case .arc:
            CodableGraphic.Content.Shape.Arc.self
        case .line:
            CodableGraphic.Content.Shape.Line.self
        }
    }
}
