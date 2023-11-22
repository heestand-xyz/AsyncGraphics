import SwiftUI

public enum ShapeGraphic3DType: String, Codable, Equatable, CaseIterable {
    
    case sphere
    case box
}

extension ShapeGraphic3DType: Identifiable {
    
    public var id: String {
        rawValue
    }
}

extension ShapeGraphic3DType {
    
    public var type: ShapeGraphic3DProtocol.Type {
        switch self {
        case .sphere:
            CodableGraphic3D.Content.Shape.Sphere.self
        case .box:
            CodableGraphic3D.Content.Shape.Box.self
        }
    }
}
