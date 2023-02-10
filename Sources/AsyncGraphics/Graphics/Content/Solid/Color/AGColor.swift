import CoreGraphics
import PixelColor

public struct AGColor: AGGraph {
    
    public let width: CGFloat? = nil
    public let height: CGFloat? = nil
    
    let color: PixelColor
    let options: Graphic.ContentOptions
    
    public init(_ color: PixelColor,
                options: Graphic.ContentOptions = .init()) {
        self.color = color
        self.options = options
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        try await .color(color, resolution: resolution, options: options)
    }
}