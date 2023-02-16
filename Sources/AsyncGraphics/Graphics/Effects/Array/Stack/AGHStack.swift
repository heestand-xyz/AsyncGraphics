import CoreGraphics

public struct AGHStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.HStackAlignment
    
    public init(alignment: Graphic.HStackAlignment = .center,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    public func contentResolution(with details: AGResolutionDetails) -> AGResolution {
        let width: CGFloat? = {
            var totalWidth: CGFloat = 0.0
            for graph in graphs.all {
                if let width = graph.contentResolution(with: details).width {
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
                if let height = graph.contentResolution(with: details).height {
                    totalHeight = max(totalHeight, height)
                } else {
                    return nil
                }
            }
            return totalHeight
        }()
        return AGResolution(width: width, height: height)
    }
    
    func childResolution(for childGraph: any AGGraph, at index: Int,
                         with resolutionDetails: AGResolutionDetails) -> CGSize {
        let contentResolution: AGResolution = childGraph.contentResolution(with: resolutionDetails)
        var width: CGFloat = contentResolution.width ?? resolutionDetails.resolution.width
        let height: CGFloat = contentResolution.height ?? resolutionDetails.resolution.height
        if contentResolution.width == nil {
            var autoCount: Int = 1
            for (otherIndex, otherGraph) in graphs.all.enumerated() {
                guard otherIndex != index else { continue }
                if let otherWidth: CGFloat = otherGraph.contentResolution(with: resolutionDetails).width {
                    width -= otherWidth
                } else {
                    autoCount += 1
                }
            }
            width /= CGFloat(autoCount)
        }
        return CGSize(width: width, height: height)
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: details.resolution)
        }
        var graphics: [Graphic] = []
        for (index, graph) in graphs.all.enumerated() {
            let resolution: CGSize = childResolution(for: graph, at: index,
                                                     with: details.resolutionDetails)
            let details: AGRenderDetails = details.with(resolution: resolution)
            let graphic: Graphic = try await graph.render(with: details)
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
