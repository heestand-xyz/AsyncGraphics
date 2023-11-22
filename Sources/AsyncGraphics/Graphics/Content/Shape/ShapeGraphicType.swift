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
            CodableGraphic.Circle()
        case .arc:
            CodableGraphic.Arc()
        case .line:
            CodableGraphic.Line()
        }
    }
}
