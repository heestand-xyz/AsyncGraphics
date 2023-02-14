import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGRectangle: AGGraph {
    
    var lineWidth: CGFloat?
   
    let cornerRadius: CGFloat
    
    public init(cornerRadius: CGFloat = 0.0) {
        self.cornerRadius = cornerRadius
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        .auto
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        if let lineWidth: CGFloat {
            let size: CGSize = details.resolution - lineWidth / 2
            return try await .strokedRectangle(size: size,
                                               lineWidth: lineWidth,
                                               color: details.color,
                                               backgroundColor: .clear,
                                               resolution: details.resolution)
        } else {
            return try await .rectangle(cornerRadius: cornerRadius,
                                        color: details.color,
                                        backgroundColor: .clear,
                                        resolution: details.resolution)
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

