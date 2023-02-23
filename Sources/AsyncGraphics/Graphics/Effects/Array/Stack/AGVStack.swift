import CoreGraphics

public struct AGVStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.VStackAlignment
    
    public init(alignment: Graphic.VStackAlignment = .center,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.graphs = graphs()
    }
    
    private func maxWidth(for specification: AGSpecification) -> CGFloat {
        {
            var width: CGFloat = 0.0
            for childGraph in children.all {
                if let fixedWidth: CGFloat = childGraph.resolution(for: specification).fixedWidth {
                    width = max(width, fixedWidth)
                } else {
                    return nil
                }
            }
            return width
        }() ?? specification.resolution.width
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        let maxWidth: CGFloat = maxWidth(for: specification)
        var dynamicResolution: AGDynamicResolution = .zero
        for child in children.all {
            let childDynamicResolution = child.resolution(for: specification)
            dynamicResolution = dynamicResolution.vMerge(maxWidth: maxWidth,
                                                         totalHeight: specification.resolution.height,
                                                         with: childDynamicResolution)
        }
        return dynamicResolution
    }
    
    func childResolution(_ childGraph: any AGGraph, at index: Int,
                         for specification: AGSpecification) -> CGSize {
        let maxWidth: CGFloat = maxWidth(for: specification)
        let childDynamicResolution: AGDynamicResolution = childGraph.resolution(for: specification)
        let width: CGFloat = childDynamicResolution.fixedWidth ?? maxWidth
        let height: CGFloat = childDynamicResolution.fixedHeight ?? {
            var heightA: CGFloat = specification.resolution.height
            var heightB: CGFloat = specification.resolution.height
            var autoCountA: Int = 1
            var autoCountB: Int = 1
            for (otherIndex, otherGraph) in children.all.enumerated() {
                guard otherIndex != index else { continue }
                let otherChildDynamicResolution: AGDynamicResolution = otherGraph.resolution(for: specification)
                if let otherHeight = otherChildDynamicResolution.height(forWidth: maxWidth) {
                    heightA -= otherHeight
                } else {
                    autoCountA += 1
                }
                if let otherHeight = otherChildDynamicResolution.fixedHeight {
                    heightB -= otherHeight
                } else {
                    autoCountB += 1
                }
            }
            heightA /= CGFloat(autoCountA)
            heightB /= CGFloat(autoCountB)
            return max(heightA, heightB)
        }()
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
        return try await Graphic.vStacked(with: graphics, alignment: alignment)
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
