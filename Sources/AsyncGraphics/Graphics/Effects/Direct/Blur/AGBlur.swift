import CoreGraphics

extension AGGraph {
    
    public func blur(radius: CGFloat) -> any AGGraph {
        AGBlur(graph: self, radius: radius)
    }
}

public struct AGBlur: AGGraph {
    
    public var resolution: AGResolution {
        graph.resolution
    }
    
    let graph: any AGGraph
    
    let radius: CGFloat
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        try await graph.render(at: resolution).blurred(radius: radius)
    }
}

extension AGBlur: Equatable {

    public static func == (lhs: AGBlur, rhs: AGBlur) -> Bool {
        guard lhs.resolution == rhs.resolution else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGBlur: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(resolution)
        hasher.combine(graph)
    }
}
