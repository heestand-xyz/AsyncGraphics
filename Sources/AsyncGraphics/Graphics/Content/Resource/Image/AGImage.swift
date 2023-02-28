import TextureMap
import CoreGraphics
import CoreGraphicsExtensions
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct AGImage: AGGraph {
    
    enum Source: Hashable {
        case name(String)
        case raw(TMImage)
    }
    
    let source: Source
    
    var placement: Placement = .center
    
    public init(named name: String) {
        source = .name(name)
    }
    
    public init(_ image: TMImage) {
        source = .raw(image)
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        guard let imageResolution: CGSize = specification.resourceResolutions.image[source]
        else { return .auto }
        switch placement {
        case .fit:
            return .size(imageResolution.place(in: specification.resolution, placement: .fit))
        case .fill:
            return .size(imageResolution.place(in: specification.resolution, placement: .fill))
        case .center:
            return .size(imageResolution)
        case .stretch:
            return .auto
        }
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        guard let imageGraphic: Graphic = details.resources.imageGraphics[source] else {
            return try await .color(.clear, resolution: details.specification.resolution)
        }
        let resolution: CGSize = fallbackResolution(for: details.specification)
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
