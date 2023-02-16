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
    
    public func contentResolution(with details: AGResolutionDetails) -> AGResolution {
        AGResolution(CGSize.one.place(in: details.resolution, placement: .fit))
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(with: details.resolutionDetails)
            .fallback(to: details.resolution)
        return try await .polygon(count: count,
                                  cornerRadius: cornerRadius,
                                  color: details.color,
                                  backgroundColor: .clear,
                                  resolution: resolution)
    }
}
