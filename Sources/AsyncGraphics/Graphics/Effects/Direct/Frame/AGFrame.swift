import CoreGraphics

extension AGGraph {
    
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> any AGGraph {
        AGFrame(graph: self, fixedWidth: width, fixedHeight: height)
    }
}

public struct AGFrame: AGGraph {
    
    let graph: any AGGraph
    
    let fixedWidth: CGFloat?
    let fixedHeight: CGFloat?
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        AGResolution(width: fixedWidth ?? graph.contentResolution(in: containerResolution).width,
                     height: fixedHeight ?? graph.contentResolution(in: containerResolution).height)
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: details.resolution).fallback(to: details.resolution)
        return try await graph.render(with: details.with(resolution: resolution))
    }
}

extension AGFrame: Equatable {

    public static func == (lhs: AGFrame, rhs: AGFrame) -> Bool {
        guard lhs.fixedWidth == rhs.fixedWidth else { return false }
        guard lhs.fixedHeight == rhs.fixedHeight else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGFrame: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fixedWidth)
        hasher.combine(fixedHeight)
        hasher.combine(graph)
    }
}
