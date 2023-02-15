import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGRoundedPolygon: AGGraph {
   
    let count: Int
    let cornerRadius: CGFloat
    
    public init(count: Int, cornerRadius: CGFloat) {
        self.count = count
        self.cornerRadius = cornerRadius * .pixelsPerPoint
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        AGResolution(CGSize.one.place(in: containerResolution, placement: .fit))
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: details.resolution)
            .fallback(to: details.resolution)
        return try await .polygon(count: count,
                                  cornerRadius: cornerRadius,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
