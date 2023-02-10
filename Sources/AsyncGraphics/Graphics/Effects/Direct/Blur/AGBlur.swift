import CoreGraphics

extension AGGraph {
    
    public func blur(radius: CGFloat) -> any AGGraph {
        AGBlur(graph: self, radius: radius)
    }
}

public struct AGBlur: AGGraph {
    
    let graph: any AGGraph
    
    let radius: CGFloat
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        graph.contentResolution(in: containerResolution)
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: details.resolution).fallback(to: details.resolution)
        return try await graph.render(with: details.with(resolution: resolution))
            .blurred(radius: radius)
    }
}

extension AGBlur: Equatable {

    public static func == (lhs: AGBlur, rhs: AGBlur) -> Bool {
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGBlur: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(graph)
    }
}
