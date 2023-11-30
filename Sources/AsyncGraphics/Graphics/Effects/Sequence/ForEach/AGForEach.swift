import CoreGraphics

public struct AGForEach: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    var graphs: [any AGGraph]
    
    public init(_ range: Range<Int>, @AGGraphBuilder graphs: (Int) -> [any AGGraph]) {
        self.graphs = range.flatMap { graphs($0) }
    }
    
    public init(_ range: ClosedRange<Int>, graph: (Int) -> any AGGraph) {
        self.graphs = range.map { graph($0) }
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await .color(.clear, resolution: resolution)
    }
}

extension AGForEach: Equatable {
    
    public static func == (lhs: AGForEach, rhs: AGForEach) -> Bool {
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsGraph, rhsGraph) in zip(lhs.graphs, rhs.graphs) {
            guard lhsGraph.isEqual(to: rhsGraph) else { return false }
        }
        return true
    }
}

extension AGForEach: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
