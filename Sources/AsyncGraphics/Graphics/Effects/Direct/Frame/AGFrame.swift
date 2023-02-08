import CoreGraphics

extension AGGraph {
    
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> any AGGraph {
        AGFrame(graph: self, width: width, height: height)
    }
}

public struct AGFrame: AGGraph {
    
    let graph: any AGGraph
    
    public let width: CGFloat?
    public let height: CGFloat?
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        let resolution = CGSize(width: width ?? resolution.width,
                                height: height ?? resolution.height)
        return try await graph.render(at: resolution)
    }
}

extension AGFrame: Equatable {

    public static func == (lhs: AGFrame, rhs: AGFrame) -> Bool {
        guard lhs.width == rhs.width else { return false }
        guard lhs.height == rhs.height else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGFrame: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(graph)
    }
}
