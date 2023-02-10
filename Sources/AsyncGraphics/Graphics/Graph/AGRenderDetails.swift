import CoreGraphics
import PixelColor

public struct AGRenderDetails {
    let resolution: CGSize
    let color: PixelColor
}

extension AGRenderDetails {
    
    func with(resolution: CGSize) -> AGRenderDetails {
        AGRenderDetails(resolution: resolution, color: color)
    }
    
    func with(color: PixelColor) -> AGRenderDetails {
        AGRenderDetails(resolution: resolution, color: color)
    }
}
