import CoreGraphics
import PixelColor

public struct AGRenderDetails: Equatable {
    var color: PixelColor = .primary
    let resources: AGResources
    let specification: AGSpecification
}

extension AGRenderDetails {
    
    func with(resolution: CGSize) -> AGRenderDetails {
        AGRenderDetails(color: color, resources: resources, specification: specification.with(resolution: resolution))
    }
    
    func with(color: PixelColor) -> AGRenderDetails {
        AGRenderDetails(color: color, resources: resources, specification: specification)
    }
}
