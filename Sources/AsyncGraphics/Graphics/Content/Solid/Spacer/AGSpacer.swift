import CoreGraphics

public struct AGSpacer: AGGraph {
    
    public init() {}
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = fallbackResolution(for: details.specification)
        return try await .color(.clear, resolution: resolution)
    }
}
