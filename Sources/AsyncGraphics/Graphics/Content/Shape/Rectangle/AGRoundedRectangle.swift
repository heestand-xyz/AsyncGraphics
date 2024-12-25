import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public struct AGRoundedRectangle: AGGraph {
    
    public var children: [any AGGraph] { [] }
    
    var lineWidth: CGFloat?
   
    let cornerRadius: CGFloat
    
    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius * .pixelsPerPoint
    }
    
    @MainActor
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
            return try await .rectangle(cornerRadius: cornerRadius,
                                        color: details.color,
                                        backgroundColor: .clear,
                                        resolution: resolution)
        }
    }
}

extension AGRoundedRectangle {
    
    public func strokeBorder(lineWidth: CGFloat = 1.0) -> AGRoundedRectangle {
        var circle: AGRoundedRectangle = self
        circle.lineWidth = lineWidth * .pixelsPerPoint
        return circle
    }
}

