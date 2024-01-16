import TextureMap
import CoreGraphics
import CoreGraphicsExtensions
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct AGImage: AGGraph {
    
    enum Source: Hashable {
        case name(String)
        case raw(TMImage)
    }
    
    let source: Source
    
    var placement: Graphic.Placement = .fixed
    
    public init(named name: String) {
        source = .name(name)
    }
    
    public init(_ image: TMImage) {
        source = .raw(image)
    }
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        guard let imageResolution: CGSize = specification.resourceResolutions.image[source]
        else { return proposedResolution }
        switch placement {
        case .fit:
            return imageResolution.place(in: proposedResolution, placement: .fit)
        case .fill:
            return imageResolution.place(in: proposedResolution, placement: .fill)
        case .fixed:
            return imageResolution
        case .stretch:
            return proposedResolution
        }
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        guard let imageGraphic: Graphic = details.resources.imageGraphics[source] else {
            return try await .color(.clear, resolution: resolution)
        }
        return try await imageGraphic.resized(to: resolution, placement: .stretch, method: .lanczos)
    }
}

extension AGImage {
    
    public func resizable() -> AGImage {
        var image: AGImage = self
        image.placement = .stretch
        return image
    }
}

extension AGImage {
    
    public func aspectRatio(contentMode: AGContentMode) -> AGImage {
        var image: AGImage = self
        switch contentMode {
        case .fit:
            image.placement = .fit
        case .fill:
            image.placement = .fill
        }
        return image
    }
}
