import CoreGraphics

extension AGGraph {
    
    public func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: AGContentMode) -> any AGGraph {
        AGAspectRatio(graph: self, aspectRatio: aspectRatio, contentMode: contentMode)
    }
    
    public func aspectRatio(_ aspectRatio: CGSize, contentMode: AGContentMode) -> any AGGraph {
        AGAspectRatio(graph: self, aspectRatio: aspectRatio.width / aspectRatio.height, contentMode: contentMode)
    }
}

public struct AGAspectRatio: AGGraph {
    
    public let resolution: AGResolution = .auto
    
    let graph: any AGGraph
    
    let aspectRatio: CGFloat?
    let contentMode: AGContentMode
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        let placementResolution: CGSize = {
            if let graphResolution = graph.resolution.size {
                let placement: Placement = {
                    switch contentMode {
                    case .fit:
                        return .fit
                    case .fill:
                        return .fill
                    }
                }()
                return graphResolution.place(in: resolution, placement: placement)
            } else if let graphWidth = graph.resolution.width {
                return CGSize(width: graphWidth, height: resolution.height)
            } else if let graphHeight = graph.resolution.height {
                return CGSize(width: resolution.width, height: graphHeight)
            } else {
                return resolution
            }
        }()
        return try await graph.render(at: placementResolution)
    }
}

extension AGAspectRatio: Equatable {

    public static func == (lhs: AGAspectRatio, rhs: AGAspectRatio) -> Bool {
        guard lhs.resolution == rhs.resolution else { return false }
        guard lhs.aspectRatio == rhs.aspectRatio else { return false }
        guard lhs.contentMode == rhs.contentMode else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGAspectRatio: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(resolution)
        hasher.combine(aspectRatio)
        hasher.combine(contentMode)
        hasher.combine(graph)
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
