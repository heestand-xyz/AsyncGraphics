import SwiftUI

public enum ShapeGraphic2DType: String, Codable, Equatable, CaseIterable {
    
    case circle
    case arc
    case line
}

extension ShapeGraphic2DType: Identifiable {
    
    public var id: String {
        rawValue
    }
}

extension ShapeGraphic2DType {
    
    public func instance() -> ShapeGraphic2DProtocol {
        switch self {
        case .circle:
            CodableGraphic2D.Circle()
        case .arc:
            CodableGraphic2D.Arc()
        case .line:
            CodableGraphic2D.Line()
        }
    }
}
