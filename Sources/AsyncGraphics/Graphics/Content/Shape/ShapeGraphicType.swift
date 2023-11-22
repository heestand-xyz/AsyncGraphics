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
    
    public func instance() -> ShapeGraphicProtocol {
        switch self {
        case .circle:
            CodableGraphic.Content.Shape.Circle()
        case .arc:
            CodableGraphic.Content.Shape.Arc()
        case .line:
            CodableGraphic.Content.Shape.Line()
        }
    }
}
