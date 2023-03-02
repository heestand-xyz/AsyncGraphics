import CoreGraphics

public struct AGSpacer: AGGraph {
    
    let minLength: CGFloat
    
    public init(minLength: CGFloat = 8) {
        self.minLength = minLength * .pixelsPerPoint
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        .spacer(minLength: minLength)
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = fallbackResolution(for: details.specification)
        return try await .color(.clear, resolution: resolution)
    }
}
