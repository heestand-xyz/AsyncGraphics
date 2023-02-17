import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGRectangle: AGGraph {
    
    var lineWidth: CGFloat?
   
    public init() {}
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        .auto
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        if let lineWidth: CGFloat {
            let size: CGSize = details.specification.resolution - lineWidth / 2
            return try await .strokedRectangle(size: size,
                                               lineWidth: lineWidth,
                                               color: details.color,
                                               backgroundColor: .clear,
                                               resolution: details.specification.resolution)
        } else {
            return try await .rectangle(color: details.color,
                                        backgroundColor: .clear,
                                        resolution: details.specification.resolution)
        }
    }
}

extension AGRectangle {
    
    public func strokeBorder(lineWidth: CGFloat = 1.0) -> AGRectangle {
        var circle: AGRectangle = self
        circle.lineWidth = lineWidth * .pixelsPerPoint
        return circle
    }
}

