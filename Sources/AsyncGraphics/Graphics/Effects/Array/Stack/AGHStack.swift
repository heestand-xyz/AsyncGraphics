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
    
    private func autoSpecification(for specification: AGSpecification) -> AGSpecification {
        let autoResolution = CGSize(width: specification.resolution.width / CGFloat(children.all.count),
                                    height: specification.resolution.height)
        return specification.with(resolution: autoResolution)
    }
    
    private func autoHeight(_ childGraph: any AGGraph,
                            for specification: AGSpecification) -> CGFloat? {
        let autoSpecification = autoSpecification(for: specification)
        let dynamicChildResolution: AGDynamicResolution = childGraph.resolution(for: autoSpecification)
        return dynamicChildResolution.fixedHeight
    }
    
    private func autoWidth(_ childGraph: any AGGraph,
                           height: CGFloat?,
                           for specification: AGSpecification) -> CGFloat? {
        let autoSpecification = autoSpecification(for: specification)
        let dynamicChildResolution: AGDynamicResolution = childGraph.resolution(for: autoSpecification)
        if let height {
            if let dynamicWidth = dynamicChildResolution.width(forHeight: height) {
                return min(dynamicWidth, autoSpecification.resolution.width)
            }
            return nil
        }
        return dynamicChildResolution.fixedWidth
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        let height: CGFloat? = {
            var height: CGFloat = 0.0
            for childGraph in children.all {
                if let childHeight: CGFloat = autoHeight(childGraph, for: specification) {
                    height = max(height, childHeight)
                } else {
                    return nil
                }
            }
            return height
        }()
        let width: CGFloat? = {
            var width: CGFloat = 0.0
            for childGraph in children.all {
                if let childWidth: CGFloat = autoWidth(childGraph, height: height, for: specification) {
                    width += childWidth
                } else {
                    return nil
                }
            }
            return width
        }()
        return .semiAuto(width: width, height: height)
    }
    
    func childResolution(_ childGraph: any AGGraph, at index: Int,
                         for specification: AGSpecification) -> CGSize {
        let resolution = resolution(for: specification)
        let autoHeight: CGFloat? = autoHeight(childGraph, for: specification)
        let autoWidth: CGFloat? = autoWidth(childGraph, height: resolution.fixedHeight, for: specification)
        let height: CGFloat = autoHeight ?? specification.resolution.height
        var width: CGFloat = autoWidth ?? specification.resolution.width
        if autoWidth == nil {
            var autoCount: Int = 1
            for (otherIndex, otherGraph) in graphs.all.enumerated() {
                guard otherIndex != index else { continue }
                if let otherWidth = self.autoWidth(otherGraph, height: resolution.fixedHeight, for: specification) {
                    width -= otherWidth
                } else {
                    autoCount += 1
                }
            }
            width /= CGFloat(autoCount)
        }
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
