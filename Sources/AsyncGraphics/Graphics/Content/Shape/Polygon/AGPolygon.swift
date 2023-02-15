import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGPolygon: AGGraph {
    
    let count: Int
    
    public init(count: Int) {
        self.count = count
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        AGResolution(CGSize.one.place(in: containerResolution, placement: .fit))
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: details.resolution)
            .fallback(to: details.resolution)
        return try await .polygon(count: count,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
