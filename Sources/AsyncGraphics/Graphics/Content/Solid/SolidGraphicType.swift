import SwiftUI

public enum SolidGraphicType: String, Codable, Equatable, CaseIterable {
    
    case color
}

extension SolidGraphicType: Identifiable {
    
    public var id: String {
        rawValue
    }
}

extension SolidGraphicType {
    
    public func instance() -> SolidGraphicProtocol {
        switch self {
        case .color:
            CodableGraphic.Content.Solid.Color()
        }
    }
}
