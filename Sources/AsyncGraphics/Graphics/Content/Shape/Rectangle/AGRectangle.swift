import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGRectangle: AGGraph {
    
    var lineWidth: CGFloat?
   
    public init() {}
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        if let lineWidth: CGFloat {
            let size: CGSize = resolution - lineWidth / 2
            return try await .strokedRectangle(size: size,
                                               lineWidth: lineWidth,
                                               color: details.color,
                                               backgroundColor: .clear,
                                               resolution: resolution)
        } else {
            return try await .rectangle(color: details.color,
                                        backgroundColor: .clear,
                                        resolution: resolution)
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

