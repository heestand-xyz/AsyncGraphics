import CoreGraphics

public struct AGZStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.ZStackAlignment

    @MainActor 
    public init(alignment: Graphic.ZStackAlignment = .center,
                @AGGraphBuilder with graphs: @MainActor @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        for graph in graphs.all {
            let graphResolution: CGSize = graph.resolution(at: proposedResolution,
                                                           for: specification)
            width = max(width, graphResolution.width)
            height = max(height, graphResolution.height)
        }
        return CGSize(width: width, height: height)
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: proposedResolution)
        }
        var graphics: [Graphic] = []
        for graph in graphs.all {
            let graphic: Graphic = try await graph.render(at: proposedResolution, details: details)
            graphics.append(graphic)
        }
        let blendGraphics: [Graphic.BlendedGraphic] = zip(graphs.all, graphics).map { graph, graphic in
            Graphic.BlendedGraphic(graphic: graphic, blendMode: graph.components.blendMode ?? .over)
        }
        return try await Graphic.zBlendStacked(with: blendGraphics, alignment: alignment)
    }
}

extension AGZStack: Equatable {

    public static func == (lhs: AGZStack, rhs: AGZStack) -> Bool {
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
        }
        return true
    }
}

extension AGZStack: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
