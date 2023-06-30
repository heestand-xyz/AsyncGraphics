#if !os(xrOS)

import CoreGraphics
import CoreGraphicsExtensions
import AVKit

public struct AGCamera: AGGraph {
    
    let position: Graphic.CameraPosition
    
    var placement: Placement = .center
    
    public init(_ position: Graphic.CameraPosition) {
        self.position = position
    }
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        guard let cameraResolution: CGSize = specification.resourceResolutions.camera[position]
        else { return proposedResolution }
        switch placement {
        case .fit:
            return cameraResolution.place(in: proposedResolution, placement: .fit)
        case .center:
            return cameraResolution
        case .stretch, .fill:
            return proposedResolution
        }
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        guard let cameraGraphic: Graphic = details.resources.cameraGraphics[position] else {
            return try await .color(.black, resolution: resolution)
        }
        return try await cameraGraphic.resized(to: resolution, placement: placement, method: .lanczos)
    }
}

extension AGCamera {
    
    public func resizable() -> AGCamera {
        var image: AGCamera = self
        image.placement = .stretch
        return image
    }
}

extension AGCamera {
    
    public func aspectRatio(contentMode: AGContentMode) -> AGCamera {
        var image: AGCamera = self
        switch contentMode {
        case .fit:
            image.placement = .fit
        case .fill:
            image.placement = .fill
        }
        return image
    }
}

extension AGCamera: Equatable {

    public static func == (lhs: AGCamera, rhs: AGCamera) -> Bool {
        guard lhs.position == rhs.position else { return false }
        guard lhs.placement == rhs.placement else { return false }
        return true
    }
}

extension AGCamera: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(placement)
    }
}

#endif
