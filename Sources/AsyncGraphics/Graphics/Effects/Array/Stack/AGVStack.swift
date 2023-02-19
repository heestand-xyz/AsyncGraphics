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
    
    #warning("auto divide is off")
    func autoChildResolution(_ childGraph: any AGGraph, at index: Int,
                                for specification: AGSpecification) -> CGSize {
        CGSize(width: specification.resolution.width,
               height: specification.resolution.height / CGFloat(children.all.count))
    }
    
    func dynamicChildResolution(_ childGraph: any AGGraph, at index: Int,
                                for specification: AGSpecification) -> AGDynamicResolution {
        let autoResolution: CGSize = autoChildResolution(childGraph, at: index, for: specification)
        let autoSpecification: AGSpecification = specification.with(resolution: autoResolution)
        return childGraph.resolution(for: autoSpecification)
    }
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        if children.all.isEmpty {
            return .auto
        }
        var dynamicResolution: AGDynamicResolution = .auto
        for (index, childGraph) in children.all.enumerated() {
            let dynamicChildResolution: AGDynamicResolution = dynamicChildResolution(
                childGraph, at: index, for: specification)
            dynamicResolution.max(width: dynamicChildResolution.width)
            dynamicResolution.add(height: dynamicChildResolution.height)
        }
        return dynamicResolution
    }
    
    func childResolution(_ childGraph: any AGGraph, at index: Int,
                         for specification: AGSpecification) -> CGSize {
        let dynamicResolution: AGDynamicResolution = resolution(for: specification)
        let width: CGFloat = dynamicResolution.width ?? specification.resolution.height
        var height: CGFloat = dynamicResolution.height ?? specification.resolution.height
        if dynamicResolution.height == nil {
            var autoCount: Int = 1
            for (otherIndex, otherGraph) in graphs.all.enumerated() {
                guard otherIndex != index else { continue }
                let otherDynamicResolution: AGDynamicResolution = dynamicChildResolution(
                    otherGraph, at: otherIndex, for: specification)
                if let otherHeight = otherDynamicResolution.height {
                    height -= otherHeight
                } else {
                    autoCount += 1
                }
            }
            height /= CGFloat(autoCount)
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
