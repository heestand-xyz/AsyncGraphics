import CoreGraphics

extension AGGraph {
    
    public func opacity(_ opacity: CGFloat) -> any AGGraph {
        AGOpacity(graph: self, opacity: opacity)
    }
}

public struct AGOpacity: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let opacity: CGFloat
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await graph.render(at: resolution, details: details)
            .opacity(opacity)
    }
}

extension AGOpacity: Equatable {

    public static func == (lhs: AGOpacity, rhs: AGOpacity) -> Bool {
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGOpacity: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(graph)
    }
}
