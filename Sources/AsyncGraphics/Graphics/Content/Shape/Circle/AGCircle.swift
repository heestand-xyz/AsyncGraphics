import CoreGraphics
import PixelColor

public struct AGCircle: AGGraph {
    
    public let width: CGFloat? = nil
    public let height: CGFloat? = nil
    
    let radius: CGFloat?
    let center: CGPoint?
    let color: PixelColor
    let options: Graphic.ContentOptions
    
    public init(radius: CGFloat? = nil,
                center: CGPoint? = nil,
                color: PixelColor = .white,
                options: Graphic.ContentOptions = .init()) {
        self.radius = radius
        self.center = center
        self.color = color
        self.options = options
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        try await .circle(radius: radius,
                          center: center,
                          color: color,
                          backgroundColor: .clear,
                          resolution: resolution,
                          options: options)
    }
}
