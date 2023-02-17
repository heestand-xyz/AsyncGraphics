import CoreGraphics
import PixelColor

public struct AGSpecification: Equatable {
    let resolution: CGSize
    let resourceResolutions: AGResourceResolutions
}

extension AGSpecification {
    
    func with(resolution: CGSize) -> AGSpecification {
        AGSpecification(resolution: resolution, resourceResolutions: resourceResolutions)
    }
}
