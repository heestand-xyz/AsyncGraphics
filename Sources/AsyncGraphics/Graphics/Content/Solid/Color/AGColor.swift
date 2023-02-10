import CoreGraphics
import PixelColor

public struct AGColor: AGGraph {
    
    let color: PixelColor
    let options: Graphic.ContentOptions
    
    public init(_ color: PixelColor,
                options: Graphic.ContentOptions = .init()) {
        self.color = color
        self.options = options
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        .auto
    }
    
    public func render(in containerResolution: CGSize) async throws -> Graphic {
        try await .color(color, resolution: containerResolution, options: options)
    }
}
