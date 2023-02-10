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
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        guard let imageResolution: CGSize
        else { return .auto }
        switch placement {
        case .fit:
            return AGResolution(imageResolution.place(in: containerResolution, placement: .fit))
        case .fill:
            return AGResolution(imageResolution.place(in: containerResolution, placement: .fill))
        case .center:
            return AGResolution(imageResolution)
        case .stretch:
            return .auto
        }
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        guard let image: TMImage else {
            return try await .color(.clear, resolution: details.resolution)
        }
        let imageGraphic: Graphic = try await .image(image)
        let contentResolution: AGResolution = contentResolution(in: details.resolution)
        let resolution: CGSize = contentResolution.fallback(to: details.resolution)
        return try await imageGraphic.resized(to: resolution, method: .lanczos)
    }
}

extension AGImage {
    
    public func resizable() -> AGImage {
        var image: AGImage = self
        image.placement = .stretch
        return image
    }
}
