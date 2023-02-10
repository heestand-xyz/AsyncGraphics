import TextureMap
import CoreGraphics
import CoreGraphicsExtensions

public struct AGImage: AGGraph {
    
    public var resolution: AGResolution {
        guard let imageResolution: CGSize
        else { return .auto }
        switch placement {
        case .fit:
            return .auto
        case .fill:
            return .auto
        case .center:
            return AGResolution(imageResolution)
        case .stretch:
            return .auto
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
