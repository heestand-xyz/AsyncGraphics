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
        let placement: Placement = {
            switch contentMode {
            case .fit:
                return .fit
            case .fill:
                return .fill
            }
        }()
        if let aspectRatio {
            return AGResolution(
                CGSize(width: aspectRatio, height: 1.0)
                    .place(in: containerResolution, placement: placement)
            )
        }
        if let size = resolution.size {
            return AGResolution(size.place(in: containerResolution, placement: placement))
        } else if let width = resolution.width {
            return AGResolution(width: width)
        } else if let height = resolution.height {
            return AGResolution(height: height)
        } else {
            return .auto
        }
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: details.resolution).fallback(to: details.resolution)
        let graphic: Graphic = try await graph.render(with: details.with(resolution: resolution))
        if aspectRatio != nil {
            let backgroundGraphic: Graphic = try await .color(.clear, resolution: resolution)
            return try await backgroundGraphic.blended(with: graphic, blendingMode: .over, placement: .center)
        } else {
            return graphic
        }
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
