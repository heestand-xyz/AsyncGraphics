//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023/02/06.
//

import CoreGraphics
import PixelColor

public struct GRectangle: G {
    
    let size: CGSize
    let center: CGPoint?
    let cornerRadius: CGFloat
    let color: PixelColor
    let backgroundColor: PixelColor
    let options: Graphic.ContentOptions
    
    public init(size: CGSize,
                center: CGPoint? = nil,
                cornerRadius: CGFloat = 0.0,
                color: PixelColor = .white,
                backgroundColor: PixelColor = .black,
                options: Graphic.ContentOptions = .init()) {
        self.size = size
        self.center = center
        self.cornerRadius = cornerRadius
        self.color = color
        self.backgroundColor = backgroundColor
        self.options = options
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        try await .rectangle(size: size,
                             center: center,
                             cornerRadius: cornerRadius,
                             color: color,
                             backgroundColor: backgroundColor,
                             resolution: resolution,
                             options: options)
    }
}
