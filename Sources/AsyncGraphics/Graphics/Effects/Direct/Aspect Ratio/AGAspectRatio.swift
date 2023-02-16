import CoreGraphics

extension AGGraph {
    
    public func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: AGContentMode) -> any AGGraph {
        AGAspectRatio(graph: self, aspectRatio: aspectRatio, contentMode: contentMode)
    }
    
    public func aspectRatio(_ aspectRatio: CGSize, contentMode: AGContentMode) -> any AGGraph {
        AGAspectRatio(graph: self, aspectRatio: aspectRatio.width / aspectRatio.height, contentMode: contentMode)
    }
}

public struct AGAspectRatio: AGParentGraph {
   
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let aspectRatio: CGFloat?
    let contentMode: AGContentMode
    
    public func contentResolution(with details: AGResolutionDetails) -> AGResolution {
        let resolution: AGResolution = graph.contentResolution(with: details)
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
                    .place(in: details.resolution, placement: placement)
            )
        }
        if let size = resolution.size {
            return AGResolution(size.place(in: details.resolution, placement: placement))
        } else if let width = resolution.width {
            return AGResolution(width: width)
        } else if let height = resolution.height {
            return AGResolution(height: height)
        } else {
            return .auto
        }
    }
    
    func childResolution(for childGraph: any AGGraph, at index: Int = 0,
                         with resolutionDetails: AGResolutionDetails) -> CGSize {
        contentResolution(with: resolutionDetails)
            .fallback(to: resolutionDetails.resolution)
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let childResolution: CGSize = childResolution(for: graph, with: details.resolutionDetails)
        let graphic: Graphic = try await graph.render(with: details.with(resolution: childResolution))
        if aspectRatio != nil {
            let backgroundGraphic: Graphic = try await .color(.clear, resolution: childResolution)
            return try await backgroundGraphic.blended(with: graphic,
                                                       blendingMode: .over,
                                                       placement: .center)
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
