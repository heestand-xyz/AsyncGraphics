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
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        .fixed(CGSize.one.place(in: specification.resolution, placement: .fit))
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = fallbackResolution(for: details.specification)
        return try await .polygon(count: count,
                                  cornerRadius: cornerRadius,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
