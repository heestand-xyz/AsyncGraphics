import TextureMap
import CoreGraphics
import CoreGraphicsExtensions

public struct AGImage: AGGraph {
    
    public var width: CGFloat? {
        guard placement == .center,
              let image else { return nil }
        return image.size.width * image.scale
    }
    public var height: CGFloat? {
        guard placement == .center,
              let image else { return nil }
        return image.size.height * image.scale
    }
    
    var image: TMImage?
    
    let placement: Placement
    
    public init(named name: String, placement: Placement = .center) {
        if let image = TMImage(named: name) {
            self.image = image
        }
        self.placement = placement
    }
    
    public init(_ image: TMImage, placement: Placement = .center) {
        self.image = image
        self.placement = placement
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        guard let image: TMImage else {
            return try await .color(.clear, resolution: resolution)
        }
        return try await .image(image).resized(to: resolution, placement: placement, method: .lanczos)
    }
}

//extension AGImage {
//
//    static func lowResHash(image: TMImage) -> Int {
//        let dispatchGroup = DispatchGroup()
//        dispatchGroup.enter()
//        var hash: Int = 0
//        Task {
//            defer {
//                dispatchGroup.leave()
//            }
//            guard let graphic: Graphic = try? await .image(image).resized(to: CGSize(width: 10, height: 10), method: .lanczos),
//                  let allPixels: [[PixelColor]] = graphic.pixelColors
//            else { return }
//            let hasher = Hasher()
//            for pixels in allPixels {
//                for pixel in pixels {
//                    hasher.combine(pixel)
//                }
//            }
//            hash =
//        }
//    }
//}
