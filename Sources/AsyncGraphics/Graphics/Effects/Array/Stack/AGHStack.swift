import CoreGraphics

public struct AGHStack: AGGraph {
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.HStackAlignment
    
    public init(alignment: Graphic.HStackAlignment = .center,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        let width: CGFloat? = {
            var totalWidth: CGFloat = 0.0
            for graph in graphs.all {
                if let width = graph.contentResolution(in: containerResolution).width {
                    totalWidth = totalWidth + width
                } else {
                    return nil
                }
            }
            return totalWidth
        }()
        let height: CGFloat? = {
            var totalHeight: CGFloat = 0.0
            for graph in graphs.all {
                if let height = graph.contentResolution(in: containerResolution).height {
                    totalHeight = max(totalHeight, height)
                } else {
                    return nil
                }
            }
            return totalHeight
        }()
        return AGResolution(width: width, height: height)
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: details.resolution)
        }
        var graphics: [Graphic] = []
        for (index, graph) in graphs.all.enumerated() {
            let resolution: CGSize = {
                let contentResolution: AGResolution = graph.contentResolution(in: details.resolution)
                var width: CGFloat = contentResolution.width ?? details.resolution.width
                let height: CGFloat = contentResolution.height ?? details.resolution.height
                if contentResolution.width == nil {
                    var autoCount: Int = 1
                    for (otherIndex, otherGraph) in graphs.all.enumerated() {
                        guard otherIndex != index else { continue }
                        if let otherWidth: CGFloat = otherGraph.contentResolution(in: details.resolution).width {
                            width -= otherWidth
                        } else {
                            autoCount += 1
                        }
                    }
                    width /= CGFloat(autoCount)
                }
                return CGSize(width: width, height: height)
            }()
            let graphic: Graphic = try await graph.render(with: details.with(resolution: resolution))
            graphics.append(graphic)
        }
        return try await Graphic.hStacked(with: graphics, alignment: alignment)
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
