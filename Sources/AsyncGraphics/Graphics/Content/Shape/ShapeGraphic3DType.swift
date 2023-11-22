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
    
    public func instance() -> ShapeGraphic3DProtocol {
        switch self {
        case .sphere:
            CodableGraphic3D.Sphere()
        case .box:
            CodableGraphic3D.Box()
        }
    }
}
