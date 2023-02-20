import CoreGraphics

public struct AGZStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.ZStackAlignment
    
    public init(alignment: Graphic.ZStackAlignment = .center,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        let width: CGFloat? = {
            var width: CGFloat = 0.0
            for childGraph in children.all {
                let dynamicChildResolution: AGDynamicResolution = childGraph.resolution(for: specification)
                if let childWidth: CGFloat = dynamicChildResolution.fixedWidth {
                    width = max(width, childWidth)
                } else {
                    return nil
                }
            }
            return width
        }()
        let height: CGFloat? = {
            var height: CGFloat = 0.0
            for childGraph in children.all {
                let dynamicChildResolution: AGDynamicResolution = childGraph.resolution(for: specification)
                if let childHeight: CGFloat = dynamicChildResolution.fixedHeight {
                    height = max(height, childHeight)
                } else {
                    return nil
                }
            }
            return height
        }()
        return .semiAuto(width: width, height: height)
    }
    
    func childResolution(_ childGraph: any AGGraph, at index: Int,
                         for specification: AGSpecification) -> CGSize {
        let dynamicResolution: AGDynamicResolution = childGraph.resolution(for: specification)
        var width: CGFloat = dynamicResolution.fixedWidth ?? specification.resolution.width
        let height: CGFloat = dynamicResolution.fixedHeight ?? specification.resolution.height
        return CGSize(width: width, height: height)
    }
   
    public func render(with details: AGDetails) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: details.specification.resolution)
        }
        var graphics: [Graphic] = []
        for (index, graph) in graphs.all.enumerated() {
            let resolution: CGSize = childResolution(
                graph, at: index, for: details.specification)
            let details: AGDetails = details.with(resolution: resolution)
            let graphic: Graphic = try await graph.render(with: details)
            graphics.append(graphic)
        }
        return try await Graphic.zStacked(with: graphics, alignment: alignment)
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
