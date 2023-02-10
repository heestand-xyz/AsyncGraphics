import CoreGraphics
import PixelColor

public struct AGCircle: AGGraph {
    
    let radius: CGFloat?
    let center: CGPoint?
    let options: Graphic.ContentOptions
    
    public init(radius: CGFloat? = nil,
                center: CGPoint? = nil,
                options: Graphic.ContentOptions = .init()) {
        self.radius = radius
        self.center = center
        self.options = options
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        .auto
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        try await .circle(radius: radius,
                          center: center,
                          color: details.color,
                          backgroundColor: .clear,
                          resolution: details.resolution,
                          options: options)
    }
}
