import CoreGraphics
import PixelColor

public struct AGColor: AGGraph {
    
    let color: PixelColor
    
    public init(_ color: PixelColor) {
        self.color = color
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await .color(color, resolution: resolution)
    }
}
