import CoreGraphics

public struct AGVStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.VStackAlignment
    let spacing: CGFloat
    
    @MainActor
    public init(alignment: Graphic.VStackAlignment = .center,
                spacing: CGFloat = 8,
                @AGGraphBuilder with graphs: @MainActor @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.spacing = spacing * .pixelsPerPoint
        self.graphs = graphs()
    }
    
    private func stackItemResolution(at proposedResolution: CGSize) -> CGSize {
        CGSize(width: proposedResolution.width,
               height: (proposedResolution.height - spacing * CGFloat(graphs.all.count - 1)) / CGFloat(graphs.all.count))
    }
    
    @MainActor
    private func leftoverResolution(graph: any AGGraph, index: Int,
                                    at proposedResolution: CGSize,
                                    for specification: AGSpecification) -> CGSize {
        let stackItemResolution: CGSize = stackItemResolution(at: proposedResolution)
        var height: CGFloat = proposedResolution.height - (spacing * CGFloat(graphs.all.count - 1))
        for (siblingIndex, siblingGraph) in graphs.all.enumerated() {
            if siblingIndex == index { continue }
            if let spacer = siblingGraph as? AGSpacer {
                if graph is AGSpacer {
                    let siblingResolution: CGSize = siblingGraph.resolution(at: stackItemResolution, for: specification)
                    height -= siblingResolution.height
                } else {
                    height -= spacer.minLength
                }
                continue
            }
            let siblingResolution: CGSize = siblingGraph.resolution(at: graph is AGSpacer ? proposedResolution : stackItemResolution, for: specification)
            height -= siblingResolution.height
        }
        if let spacer = graph as? AGSpacer {
            return CGSize(width: proposedResolution.width, height: max(spacer.minLength, height))
        }
        return CGSize(width: proposedResolution.width, height: height)
    }
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        var width: CGFloat = 0.0
        var height: CGFloat = spacing * CGFloat(graphs.all.count - 1)
        for (index, graph) in graphs.all.enumerated() {
            let leftoverResolution: CGSize = leftoverResolution(graph: graph, index: index, at: proposedResolution, for: specification)
            let graphResolution: CGSize = graph.resolution(at: leftoverResolution,
                                                           for: specification)
            width = max(width, graphResolution.width)
            height += graphResolution.height
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
        return try await Graphic.vStacked(with: graphics, alignment: alignment, spacing: spacing)
    }
}

extension AGVStack: Equatable {

    public static func == (lhs: AGVStack, rhs: AGVStack) -> Bool {
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
        }
        return true
    }
}

extension AGVStack: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
