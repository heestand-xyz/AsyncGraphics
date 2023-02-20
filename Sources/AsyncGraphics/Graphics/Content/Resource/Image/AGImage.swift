import TextureMap
import CoreGraphics
import CoreGraphicsExtensions

public struct AGImage: AGGraph {
    
    private var imageResolution: CGSize? {
        guard let image
        else { return nil }
        return image.size * image.scale
    }
    
    var image: TMImage?
    
    var placement: Placement = .center
    
    public init(named name: String) {
        if let image = TMImage(named: name) {
            self.image = image
        }
    }
    
    public init(_ image: TMImage) {
        self.image = image
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        guard let imageResolution: CGSize
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
        guard let image: TMImage else {
            return try await .color(.clear, resolution: details.specification.resolution)
        }
        let imageGraphic: Graphic = try await .image(image)
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
