import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGPolygon: AGGraph {
    
    let count: Int
    
    public init(count: Int) {
        self.count = count
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        .aspectRatio(1.0)
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = fallbackResolution(for: details.specification)
        return try await .polygon(count: count,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
