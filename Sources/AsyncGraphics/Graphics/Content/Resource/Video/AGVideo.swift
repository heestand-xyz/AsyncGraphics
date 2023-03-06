import CoreGraphics

public struct AGVideo: AGGraph {
    
    let videoPlayer: GraphicVideoPlayer
    
    var placement: Placement = .center
    
    public init(with videoPlayer: GraphicVideoPlayer) {
        self.videoPlayer = videoPlayer
    }
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        let videoResolution: CGSize = videoPlayer.info.resolution
        switch placement {
        case .fit:
            return videoResolution.place(in: proposedResolution, placement: .fit)
        case .fill:
            return videoResolution.place(in: proposedResolution, placement: .fill)
        case .center:
            return videoResolution
        case .stretch:
            return proposedResolution
        }
    }
    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        let videoResolution = videoPlayer.info.resolution
//        switch placement {
//        case .fit:
//            return .size(videoResolution.place(in: specification.resolution, placement: .fit))
//        case .fill:
//            return .size(videoResolution.place(in: specification.resolution, placement: .fill))
//        case .center:
//            return .size(videoResolution)
//        case .stretch:
//            return .auto
//        }
//    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        guard let videoGraphic: Graphic = details.resources.videoGraphics[videoPlayer] else {
            return try await .color(.clear, resolution: resolution)
        }
        return try await videoGraphic.resized(to: resolution, placement: .stretch, method: .lanczos)
    }
}

extension AGVideo {
    
    public func resizable() -> AGVideo {
        var image: AGVideo = self
        image.placement = .stretch
        return image
    }
}

extension AGVideo {
    
    public func aspectRatio(contentMode: AGContentMode) -> AGVideo {
        var image: AGVideo = self
        switch contentMode {
        case .fit:
            image.placement = .fit
        case .fill:
            image.placement = .fill
        }
        return image
    }
}