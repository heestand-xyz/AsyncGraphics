import CoreGraphics

public struct AGHStack: AGGraph {
    
    public let width: CGFloat? = nil
    public let height: CGFloat? = nil
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.HStackAlignment
    
    public init(alignment: Graphic.HStackAlignment = .center,
                @AGResultBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: resolution)
        }
        var graphics: [Graphic] = []
        for (index, graph) in graphs.enumerated() {
            let resolution: CGSize = {
                var width: CGFloat = graph.width ?? resolution.width
                let height: CGFloat = graph.height ?? resolution.height
                if graph.width == nil {
                    var autoCount: Int = 1
                    for (otherIndex, otherGraph) in graphs.enumerated() {
                        guard otherIndex != index else { continue }
                        if let otherWidth = otherGraph.width {
                            width -= otherWidth
                        } else {
                            autoCount += 1
                        }
                    }
                    width /= CGFloat(autoCount)
                }
                return CGSize(width: width, height: height)
            }()
            let graphic: Graphic = try await graph.render(at: resolution)
            graphics.append(graphic)
        }
        return try await Graphic.hStacked(with: graphics, alignment: alignment)
    }
}

extension AGHStack: Equatable {

    public static func == (lhs: AGHStack, rhs: AGHStack) -> Bool {
        guard lhs.width == rhs.width else { return false }
        guard lhs.height == rhs.height else { return false }
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
        }
        return true
    }
}

extension AGHStack: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
