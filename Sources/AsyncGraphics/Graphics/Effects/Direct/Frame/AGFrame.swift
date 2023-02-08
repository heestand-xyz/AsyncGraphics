import CoreGraphics

extension AGGraph {
    
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> any AGGraph {
        AGFrame(graph: self, fixedWidth: width, fixedHeight: height)
    }
}

public struct AGFrame: AGGraphDirectEffect {
    
    let graph: any AGGraph
    
    let fixedWidth: CGFloat?
    let fixedHeight: CGFloat?
    
    public var width: CGFloat? { fixedWidth ?? graph.width }
    public var height: CGFloat? { fixedHeight ?? graph.height }
    
    public func renderDirectEffect(at resolution: CGSize) async throws -> Graphic {
        let resolution = CGSize(width: fixedWidth ?? resolution.width,
                                height: fixedHeight ?? resolution.height)
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
        hasher.combine(fixedWidth)
        hasher.combine(fixedHeight)
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(graph)
    }
}
