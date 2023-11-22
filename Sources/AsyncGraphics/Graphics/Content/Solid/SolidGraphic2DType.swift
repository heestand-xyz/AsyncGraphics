import SwiftUI

public enum SolidGraphic2DType: String, Codable, Equatable, CaseIterable {
    
    case color
}

extension SolidGraphic2DType: Identifiable {
    
    public var id: String {
        rawValue
    }
}

extension SolidGraphic2DType {
    
    public func instance() -> SolidGraphic2DProtocol {
        switch self {
        case .color:
            CodableGraphic2D.Color()
        }
    }
}
