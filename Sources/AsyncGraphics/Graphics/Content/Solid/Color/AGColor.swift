import CoreGraphics
import PixelColor

public struct AGColor: AGGraph {
    
    let color: PixelColor
    
    public init(_ color: PixelColor) {
        self.color = color
    }
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        .auto
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        try await .color(color, resolution: details.specification.resolution)
    }
}
