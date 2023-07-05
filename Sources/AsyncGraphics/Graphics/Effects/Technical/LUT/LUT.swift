import Foundation

extension Graphic {
    
    public func lut(named name: String) async throws -> Graphic {
        try await lut(named: name, in: .main)
    }
    
    public func lut(named name: String, in bundle: Bundle) async throws -> Graphic {
        // ...
        return self
    }
}
