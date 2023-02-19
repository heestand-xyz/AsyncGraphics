import CoreGraphics
import PixelColor

public struct AGColor: AGGraph {
    
    let color: PixelColor
    
    public init(_ color: PixelColor) {
        self.color = color
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = fallbackResolution(for: details.specification)
        return try await .color(color, resolution: resolution)
    }
}
