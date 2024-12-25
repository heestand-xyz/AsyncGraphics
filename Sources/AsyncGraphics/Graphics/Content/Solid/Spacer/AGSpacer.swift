import CoreGraphics

public struct AGSpacer: AGGraph {
    
    let minLength: CGFloat
    
    public init(minLength: CGFloat = 8) {
        self.minLength = minLength * .pixelsPerPoint
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await .color(.clear, resolution: resolution)
    }
}
