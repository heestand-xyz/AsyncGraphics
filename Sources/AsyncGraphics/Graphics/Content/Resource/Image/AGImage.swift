import TextureMap
import CoreGraphics
import CoreGraphicsExtensions

public struct AGImage: AGGraph {
    
    public var width: CGFloat? {
        guard let imageResolution: CGSize
        else { return nil }
        switch placement {
        case .fit:
            return nil
        case .fill:
            return nil
        case .center:
            return imageResolution.width
        case .stretch:
            return nil
        }
    }
    public var height: CGFloat? {
        guard let imageResolution: CGSize
        else { return nil }
        switch placement {
        case .fit:
            return nil
        case .fill:
            return nil
        case .center:
            return imageResolution.height
        case .stretch:
            return nil
        }
    }
    
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
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        guard let image: TMImage,
              let imageResolution: CGSize else {
            return try await .color(.clear, resolution: resolution)
        }
        let imageGraphic: Graphic = try await .image(image)
        switch placement {
        case .fit, .fill:
            let resolution: CGSize = imageResolution.place(in: resolution, placement: placement)
            return try await imageGraphic.resized(to: resolution, method: .lanczos)
        case .center:
            return imageGraphic
        case .stretch:
            return try await imageGraphic.resized(to: resolution, placement: .stretch, method: .lanczos)
        }
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
    
    public enum ContentMode {
        case fit
        case fill
    }
    
    public func aspectRatio(contentMode: ContentMode) -> AGImage {
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
