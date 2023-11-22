import SwiftUI

public enum SolidGraphicType: String, Codable, Equatable, CaseIterable {
    
    case color
    case gradient
}

extension SolidGraphicType: Identifiable {
    
    public var id: String {
        rawValue
    }
}

extension SolidGraphicType {
    
    public var type: SolidGraphicProtocol.Type {
        switch self {
        case .color:
            CodableGraphic.Content.Solid.Color.self
        case .gradient:
            CodableGraphic.Content.Solid.Gradient.self
        }
    }
}
