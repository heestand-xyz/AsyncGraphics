//
//  Created by Anton Heestand on 2022-04-03.
//

import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

public extension Graphic {

    static func circle(color: PixelColor = .white,
                       backgroundColor: PixelColor = .black,
                       size: CGSize,
                       frame: CGRect) async throws -> Graphic {
        
        let resolution: CGSize = size.resolution
        
        let radius: CGFloat = min(frame.width, frame.height) / 2
        let relativeRadius: CGFloat = radius / size.height
        
        let position: CGPoint = frame.center
        let relativePosition: CGPoint = (position - size / 2) / size.height
        #warning("Flip Y")
        
        let edge: CGFloat = 0.0
        
        let premultiply: Bool = true
        
        let texture = try await Renderer.render(
            shaderName: "circle",
            uniforms: [
                relativeRadius,
                relativePosition,
                edge,
                color,
                PixelColor.clear,
                backgroundColor,
                premultiply,
                resolution,
                resolution.aspectRatio
            ],
            resolution: resolution,
            bits: ._8
        )
        
        return Graphic(texture: texture, bits: ._8, colorSpace: .sRGB)
    }
}
