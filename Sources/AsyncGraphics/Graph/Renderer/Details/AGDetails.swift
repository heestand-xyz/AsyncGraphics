import CoreGraphics
import PixelColor

@MainActor
public struct AGDetails: Equatable, Sendable {
    var color: PixelColor = .primary
    let resources: AGResources
    let specification: AGSpecification
}

extension AGDetails {
    
    func with(color: PixelColor) -> AGDetails {
        AGDetails(color: color, resources: resources, specification: specification)
    }
}
