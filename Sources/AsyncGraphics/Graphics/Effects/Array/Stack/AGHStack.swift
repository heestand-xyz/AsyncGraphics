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
    
    private func maxHeight(for specification: AGSpecification) -> CGFloat {
        {
            var height: CGFloat = 0.0
            for childGraph in children.all {
                if let fixedHeight: CGFloat = childGraph.resolution(for: specification).fixedHeight {
                    height = max(height, fixedHeight)
                } else {
                    return nil
                }
            }
            return height
        }() ?? specification.resolution.height
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        let maxHeight: CGFloat = maxHeight(for: specification)
        var dynamicResolution: AGDynamicResolution = .zero
        for child in children.all {
            let childDynamicResolution = child.resolution(for: specification)
            dynamicResolution = dynamicResolution.hMerge(maxHeight: maxHeight,
                                                         totalWidth: specification.resolution.width,
                                                         with: childDynamicResolution)
        }
        return dynamicResolution
    }
    
    func childResolution(_ childGraph: any AGGraph, at index: Int,
                         for specification: AGSpecification) -> CGSize {
        let maxHeight: CGFloat = maxHeight(for: specification)
        let childDynamicResolution: AGDynamicResolution = childGraph.resolution(for: specification)
        let height: CGFloat = childDynamicResolution.fixedHeight ?? maxHeight
        let width: CGFloat = childDynamicResolution.fixedWidth ?? {
            var widthA: CGFloat = specification.resolution.width
            var widthB: CGFloat = specification.resolution.width
            var autoCountA: Int = 1
            var autoCountB: Int = 1
            for (otherIndex, otherGraph) in children.all.enumerated() {
                guard otherIndex != index else { continue }
                let otherChildDynamicResolution: AGDynamicResolution = otherGraph.resolution(for: specification)
                if let otherWidth = otherChildDynamicResolution.width(forHeight: maxHeight) {
                    widthA -= otherWidth
                } else {
                    autoCountA += 1
                }
                if let otherWidth = otherChildDynamicResolution.fixedWidth {
                    widthB -= otherWidth
                } else {
                    autoCountB += 1
                }
            }
            widthA /= CGFloat(autoCountA)
            widthB /= CGFloat(autoCountB)
            return max(widthA, widthB)
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
