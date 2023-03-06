import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGRoundedPolygon: AGGraph {
    
    public var children: [any AGGraph] { [] }
    
    let count: Int
    let cornerRadius: CGFloat
    
    public init(count: Int, cornerRadius: CGFloat) {
        self.count = count
        self.cornerRadius = cornerRadius * .pixelsPerPoint
    }
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        .one.place(in: proposedResolution, placement: .fit)
    }
    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        .aspectRatio(1.0)
//    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await .polygon(count: count,
                                  cornerRadius: cornerRadius,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
