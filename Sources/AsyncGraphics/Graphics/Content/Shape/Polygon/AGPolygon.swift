import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGPolygon: AGGraph {
    
    let count: Int
    
    public init(count: Int) {
        self.count = count
    }
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        AGResolution(CGSize.one.place(in: specification.resolution, placement: .fit))
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(with: details.specification)
            .fallback(to: details.specification.resolution)
        return try await .polygon(count: count,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
