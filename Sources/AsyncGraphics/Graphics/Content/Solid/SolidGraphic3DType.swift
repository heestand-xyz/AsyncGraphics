import SwiftUI

public enum SolidGraphic3DType: String, Codable, Equatable, CaseIterable {
    
    case color
}

extension SolidGraphic3DType: Identifiable {
    
    public var id: String {
        rawValue
    }
}

extension SolidGraphic3DType {
    
    public func instance() -> SolidGraphic3DProtocol {
        switch self {
        case .color:
            CodableGraphic3D.Content.Solid.Color()
        }
    }
}
