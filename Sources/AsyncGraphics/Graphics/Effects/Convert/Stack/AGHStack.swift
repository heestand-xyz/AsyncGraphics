import CoreGraphics

public struct AGHStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    @MainActor
    let alignment: Graphic.HStackAlignment
    let spacing: CGFloat
    
    public init(alignment: Graphic.HStackAlignment = .center,
                spacing: CGFloat = 8,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.spacing = spacing * .pixelsPerPoint
        self.graphs = graphs()
    }
    
    private func stackItemResolution(at proposedResolution: CGSize) -> CGSize {
        CGSize(width: (proposedResolution.width - spacing * CGFloat(graphs.all.count - 1)) / CGFloat(graphs.all.count),
               height: proposedResolution.height)
    }
    
    @MainActor
    private func leftoverResolution(graph: any AGGraph, index: Int,
                                    at proposedResolution: CGSize,
                                    for specification: AGSpecification) -> CGSize {
        let stackItemResolution: CGSize = stackItemResolution(at: proposedResolution)
        var width: CGFloat = proposedResolution.width - (spacing * CGFloat(graphs.all.count - 1))
        for (siblingIndex, siblingGraph) in graphs.all.enumerated() {
            if siblingIndex == index { continue }
            if let spacer = siblingGraph as? AGSpacer {
                if graph is AGSpacer {
                    let siblingResolution: CGSize = siblingGraph.resolution(at: stackItemResolution, for: specification)
                    width -= siblingResolution.width
                } else {
                    width -= spacer.minLength
                }
                continue
            }
            let siblingResolution: CGSize = siblingGraph.resolution(at: graph is AGSpacer ? proposedResolution : stackItemResolution, for: specification)
            width -= siblingResolution.width
        }
        if let spacer = graph as? AGSpacer {
            return CGSize(width: max(spacer.minLength, width), height: proposedResolution.height)
        }
        return CGSize(width: width, height: proposedResolution.height)
    }
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        var width: CGFloat = spacing * CGFloat(graphs.all.count - 1)
        var height: CGFloat = 0.0
        for (index, graph) in graphs.all.enumerated() {
            let leftoverResolution: CGSize = leftoverResolution(graph: graph, index: index, at: proposedResolution, for: specification)
            let graphResolution: CGSize = graph.resolution(at: leftoverResolution,
                                                           for: specification)
            width += graphResolution.width
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
        for (index, graph) in graphs.all.enumerated() {
            let leftoverResolution: CGSize = leftoverResolution(graph: graph, index: index, at: proposedResolution, for: details.specification)
            let graphic: Graphic = try await graph.render(at: leftoverResolution, details: details)
            graphics.append(graphic)
        }
        return try await Graphic.hStacked(with: graphics, alignment: alignment, spacing: spacing)
    }
}

extension AGHStack: Equatable {

    public static func == (lhs: AGHStack, rhs: AGHStack) -> Bool {
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
        }
        return true
    }
}

extension AGHStack: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
