import CoreGraphics

public struct AGSpacer: AGGraph {
    
    public init() {}
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        .auto
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        try await .color(.clear, resolution: details.specification.resolution)
    }
}
