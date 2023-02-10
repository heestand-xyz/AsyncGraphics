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
    
    public func render(in containerResolution: CGSize) async throws -> Graphic {
        let resolution: CGSize = contentResolution(in: containerResolution).fallback(to: containerResolution)
        return try await graph.render(in: resolution).blurred(radius: radius)
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
