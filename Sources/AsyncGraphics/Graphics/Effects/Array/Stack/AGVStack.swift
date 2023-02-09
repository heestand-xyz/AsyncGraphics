import CoreGraphics

public struct AGVStack: AGGraph {
    
    public let width: CGFloat? = nil
    public let height: CGFloat? = nil
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.VStackAlignment
    
    public init(alignment: Graphic.VStackAlignment = .center,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: resolution)
        }
        var graphics: [Graphic] = []
        for (index, graph) in graphs.allGraphs.enumerated() {
            let resolution: CGSize = {
                let width: CGFloat = graph.width ?? resolution.width
                var height: CGFloat = graph.height ?? resolution.height
                if graph.height == nil {
                    var autoCount: Int = 1
                    for (otherIndex, otherGraph) in graphs.allGraphs.enumerated() {
                        guard otherIndex != index else { continue }
                        if let otherHeight = otherGraph.height {
                            height -= otherHeight
                        } else {
                            autoCount += 1
                        }
                    }
                    height /= CGFloat(autoCount)
                }
                return CGSize(width: width, height: height)
            }()
            let graphic: Graphic = try await graph.render(at: resolution)
            graphics.append(graphic)
        }
        return try await Graphic.vStacked(with: graphics, alignment: alignment)
    }
}

extension AGVStack: Equatable {

    public static func == (lhs: AGVStack, rhs: AGVStack) -> Bool {
        guard lhs.width == rhs.width else { return false }
        guard lhs.height == rhs.height else { return false }
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
        }
        return true
    }
}

extension AGVStack: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
