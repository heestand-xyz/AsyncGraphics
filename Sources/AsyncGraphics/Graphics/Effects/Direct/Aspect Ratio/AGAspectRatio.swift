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
    
    let graph: any AGGraph
    
    let aspectRatio: CGFloat?
    let contentMode: AGContentMode
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        let resolution: AGResolution = graph.contentResolution(in: containerResolution)
        if let size = resolution.size {
            let placement: Placement = {
                switch contentMode {
                case .fit:
                    return .fit
                case .fill:
                    return .fill
                }
            }()
            return AGResolution(size.place(in: containerResolution, placement: placement))
        } else if let width = resolution.width {
            return AGResolution(width: width)
        } else if let height = resolution.height {
            return AGResolution(height: height)
        } else {
            return .auto
        }
    }
    
    public func render(in containerResolution: CGSize) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: containerResolution).fallback(to: containerResolution)
        return try await graph.render(in: resolution)
    }
}

extension AGAspectRatio: Equatable {

    public static func == (lhs: AGAspectRatio, rhs: AGAspectRatio) -> Bool {
        guard lhs.aspectRatio == rhs.aspectRatio else { return false }
        guard lhs.contentMode == rhs.contentMode else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGAspectRatio: Hashable {
    
    public func hash(into hasher: inout Hasher) {
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
