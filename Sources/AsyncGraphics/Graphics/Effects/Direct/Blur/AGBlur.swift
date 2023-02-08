import CoreGraphics

extension AGGraph {
    
    public func blur(radius: CGFloat) -> any AGGraph {
        AGBlur(graph: self, radius: radius)
    }
}

public struct AGBlur: AGGraph {
    
    public var width: CGFloat? {
        graph.width
    }
    public var height: CGFloat? {
        graph.height
    }
    
    let graph: any AGGraph
    
    let radius: CGFloat
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        try await graph.render(at: resolution).blurred(radius: radius)
    }
}

extension AGBlur: Equatable {

    public static func == (lhs: AGBlur, rhs: AGBlur) -> Bool {
        guard lhs.width == rhs.width else { return false }
        guard lhs.height == rhs.height else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGBlur: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(graph)
    }
}
