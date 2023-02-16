import CoreGraphics
import PixelColor

public struct AGRenderDetails: Equatable {
    var resolution: CGSize {
        resolutionDetails.resolution
    }
    var color: PixelColor = .primary
    let resources: AGResources
    let resolutionDetails: AGResolutionDetails
}

extension AGRenderDetails {
    
    func with(resolution: CGSize) -> AGRenderDetails {
        AGRenderDetails(color: color, resources: resources, resolutionDetails: resolutionDetails.with(resolution: resolution))
    }
    
    func with(color: PixelColor) -> AGRenderDetails {
        AGRenderDetails(color: color, resources: resources, resolutionDetails: resolutionDetails)
    }
}
