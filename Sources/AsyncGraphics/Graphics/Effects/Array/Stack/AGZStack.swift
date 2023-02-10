import CoreGraphics

public struct AGZStack: AGGraph {
    
    public var resolution: AGResolution {
        let width: CGFloat? = {
            var totalWidth: CGFloat = 0.0
            for graph in graphs.allGraphs {
                if let width = graph.width {
                    totalWidth = max(totalWidth, width)
                } else {
                    return nil
                }
            }
            return totalWidth
        }()
        let height: CGFloat? = {
            var totalHeight: CGFloat = 0.0
            for graph in graphs.allGraphs {
                if let height = graph.height {
                    totalHeight = max(totalHeight, height)
                } else {
                    return nil
                }
            }
            return totalHeight
        }()
        return AGResolution(width: width, height: height)
    }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.ZStackAlignment
    
    public init(alignment: Graphic.ZStackAlignment = .center,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: resolution)
        }
        var graphics: [Graphic] = []
        for graph in graphs.allGraphs {
            let resolution = CGSize(width: graph.width ?? resolution.width,
                                    height: graph.height ?? resolution.height)
            let graphic: Graphic = try await graph.render(at: resolution)
            graphics.append(graphic)
        }
        return try await Graphic.zStacked(with: graphics, alignment: alignment)
    }
}

extension AGZStack: Equatable {

    public static func == (lhs: AGZStack, rhs: AGZStack) -> Bool {
        guard lhs.resolution == rhs.resolution else { return false }
        guard lhs.graphs.count == rhs.graphs.count else { return false }
        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
        }
        return true
    }
}

extension AGZStack: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(resolution)
        for graph in graphs {
            hasher.combine(graph)
        }
    }
}
