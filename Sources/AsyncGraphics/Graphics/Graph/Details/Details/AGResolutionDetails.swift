import CoreGraphics
import PixelColor

public struct AGResolutionDetails: Equatable {
    let resolution: CGSize
    let resources: AGResolutionResources
}

extension AGResolutionDetails {
    
    func with(resolution: CGSize) -> AGResolutionDetails {
        AGResolutionDetails(resolution: resolution, resources: resources)
    }
}
