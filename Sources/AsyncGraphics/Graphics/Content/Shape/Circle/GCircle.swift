//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023/02/06.
//

import CoreGraphics
import PixelColor

public struct GCircle: G {
    
    let radius: CGFloat
    let center: CGPoint?
    let color: PixelColor
    let backgroundColor: PixelColor
    let options: Graphic.ContentOptions
    
    public init(radius: CGFloat,
                center: CGPoint? = nil,
                color: PixelColor = .white,
                backgroundColor: PixelColor = .black,
                options: Graphic.ContentOptions = .init()) {
        self.radius = radius
        self.center = center
        self.color = color
        self.backgroundColor = backgroundColor
        self.options = options
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        try await .circle(radius: radius,
                          center: center,
                          color: color,
                          backgroundColor: backgroundColor,
                          resolution: resolution,
                          options: options)
    }
}
