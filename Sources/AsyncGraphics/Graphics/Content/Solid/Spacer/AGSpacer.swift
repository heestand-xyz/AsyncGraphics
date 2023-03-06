import CoreGraphics

public struct AGSpacer: AGGraph {
    
    let minLength: CGFloat
    
    public init(minLength: CGFloat = 8) {
        self.minLength = minLength * .pixelsPerPoint
    }
    
//    public func resolution(at proposedResolution: CGSize, for specification: AGSpecification) -> CGSize {
//        CGSize(width: minLength, height: minLength)
//    }
    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        .spacer(minLength: minLength)
//    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await .color(.clear, resolution: resolution)
    }
}
