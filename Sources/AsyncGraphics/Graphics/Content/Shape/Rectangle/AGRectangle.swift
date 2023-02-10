import CoreGraphics
import PixelColor

public struct AGRectangle: AGGraph {
   
    let size: CGSize?
    let center: CGPoint?
    let cornerRadius: CGFloat
    let color: PixelColor
    let options: Graphic.ContentOptions
    
    public init(size: CGSize? = nil,
                center: CGPoint? = nil,
                cornerRadius: CGFloat = 0.0,
                color: PixelColor = .white,
                options: Graphic.ContentOptions = .init()) {
        self.size = size
        self.center = center
        self.cornerRadius = cornerRadius
        self.color = color
        self.options = options
    }
    
    public init(frame: CGRect,
                cornerRadius: CGFloat = 0.0,
                color: PixelColor = .white,
                options: Graphic.ContentOptions = .init()) {
        self.size = frame.size
        self.center = frame.center
        self.cornerRadius = cornerRadius
        self.color = color
        self.options = options
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        .auto
    }
    
    public func render(in containerResolution: CGSize) async throws -> Graphic {
        try await .rectangle(size: size,
                             center: center,
                             cornerRadius: cornerRadius,
                             color: color,
                             backgroundColor: .clear,
                             resolution: containerResolution,
                             options: options)
    }
}
