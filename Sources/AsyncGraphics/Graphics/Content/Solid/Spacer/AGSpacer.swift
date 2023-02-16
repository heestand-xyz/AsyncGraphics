import CoreGraphics

public struct AGSpacer: AGGraph {
    
    public init() {}
    
    public func contentResolution(with details: AGResolutionDetails) -> AGResolution {
        .auto
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        try await .color(.clear, resolution: details.resolution)
    }
}
