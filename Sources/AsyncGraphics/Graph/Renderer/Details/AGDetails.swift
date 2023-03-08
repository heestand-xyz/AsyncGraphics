import CoreGraphics
import PixelColor

public struct AGDetails: Equatable {
    var color: PixelColor = .primary
    let resources: AGResources
    let specification: AGSpecification
}

extension AGDetails {
    
    func with(color: PixelColor) -> AGDetails {
        AGDetails(color: color, resources: resources, specification: specification)
    }
}
