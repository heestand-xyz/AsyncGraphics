import CoreGraphics

extension AGGraph {
    
    public func blur(radius: CGFloat) -> any AGGraph {
        AGBlur(graph: self, radius: radius)
    }
}

public struct AGBlur: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let radius: CGFloat
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = fallbackResolution(for: details.specification)
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
