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
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        AGResolution(CGSize.one.place(in: specification.resolution, placement: .fit))
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(with: details.specification)
            .fallback(to: details.specification.resolution)
        return try await .polygon(count: count,
                                  cornerRadius: cornerRadius,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
