import CoreGraphics
import PixelColor

public struct AGCircle: AGGraph {
    
    let radius: CGFloat?
    let center: CGPoint?
    let color: PixelColor
    let options: Graphic.ContentOptions
    
    public init(radius: CGFloat? = nil,
                center: CGPoint? = nil,
                color: PixelColor = .primary,
                options: Graphic.ContentOptions = .init()) {
        self.radius = radius
        self.center = center
        self.color = color
        self.options = options
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        .auto
    }
    
    public func render(in containerResolution: CGSize) async throws -> Graphic {
        try await .circle(radius: radius,
                          center: center,
                          color: color,
                          backgroundColor: .clear,
                          resolution: containerResolution,
                          options: options)
    }
}
