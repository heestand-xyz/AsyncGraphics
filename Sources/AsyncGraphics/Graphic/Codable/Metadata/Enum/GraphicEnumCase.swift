//
//  Created by Anton Heestand on 2023-11-21.
//

import Foundation

public struct GraphicEnumCase: Codable, Identifiable, Sendable {
    
    public let rawValue: String
    public let name: String
    
    public var id: String {
        rawValue
    }
    
    public init(rawValue: String, name: String) {
        self.rawValue = rawValue
        self.name = name
    }
}
