import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGCircle: AGGraph {
    
    var lineWidth: CGFloat?
    
    public init() { }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        AGResolution(CGSize.one.place(in: containerResolution, placement: .fit))
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: details.resolution)
            .fallback(to: details.resolution)
        if let lineWidth {
            var radius: CGFloat = min(details.resolution.width, details.resolution.height) / 2
            radius -= lineWidth / 2
            return try await .strokedCircle(radius: radius,
                                            lineWidth: lineWidth,
                                            color: details.color,
                                            backgroundColor: .clear,
                                            resolution: resolution)
        } else {
            return try await .circle(color: details.color,
                                     backgroundColor: .clear,
                                     resolution: resolution)
        }
    }
}

extension AGCircle {
    
    public func strokeBorder(lineWidth: CGFloat = 1.0) -> AGCircle {
        var circle: AGCircle = self
        circle.lineWidth = lineWidth * .pixelsPerPoint
        return circle
    }
}
