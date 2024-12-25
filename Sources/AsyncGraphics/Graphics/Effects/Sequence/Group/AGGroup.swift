import CoreGraphics

public struct AGGroup: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    var graphs: [any AGGraph]
    
    public init(@AGGraphBuilder graphs: () -> [any AGGraph]) {
        self.graphs = graphs()
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await .color(.clear, resolution: resolution)
    }
}

extension AGGroup: Equatable {
    
    public static func == (lhs: AGGroup, rhs: AGGroup) -> Bool {
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsGraph, rhsGraph) in zip(lhs.graphs, rhs.graphs) {
            guard lhsGraph.isEqual(to: rhsGraph) else { return false }
        }
        return true
    }
}

extension AGGroup: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
