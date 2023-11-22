import SwiftUI

extension Angle: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = .degrees(try container.decode(Double.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(degrees)
    }
}
