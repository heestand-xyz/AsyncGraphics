//import CoreGraphics
//
//public struct AGHStack: AGParentGraph {
//    
//    public var children: [any AGGraph] { graphs }
//    
//    let graphs: [any AGGraph]
//    
//    let alignment: Graphic.HStackAlignment
//    
//    public init(alignment: Graphic.HStackAlignment = .center,
//                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
//        self.alignment = alignment
//        self.graphs = graphs()
//    }
//    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        if children.all.isEmpty {
//            return .auto
//        }
//        var width: CGFloat = 0.0
//        var height: CGFloat = 0.0
//        for (index, child) in children.all.enumerated() {
//            let childResolution: CGSize = childResolution(for: child, at: index, for: specification)
//            width += childResolution.width
//            height = max(height, childResolution.height)
//        }
//        return CGSize(width: width, height: height)
//    }
//    
//    func childResolution(_ childGraph: any AGGraph, at index: Int,
//                         for specification: AGSpecification) -> CGSize {
//        let autoResolution: CGSize = CGSize(
//            width: specification.resolution.width / CGFloat(children.all.count),
//            height: specification.resolution.height)
//        return childGraph.resolution(for: specification.with(resolution: autoResolution))
//    }
//    
//    public func render(with details: AGDetails) async throws -> Graphic {
//        guard !graphs.isEmpty else {
//            return try await .color(.clear, resolution: details.specification.resolution)
//        }
//        var graphics: [Graphic] = []
//        for (index, graph) in graphs.all.enumerated() {
//            let resolution: CGSize = childResolution(for: graph, at: index,
//                                                     with: details.specification)
//            let details: AGDetails = details.with(resolution: resolution)
//            let graphic: Graphic = try await graph.render(with: details)
//            graphics.append(graphic)
//        }
//        return try await Graphic.hStacked(with: graphics, alignment: alignment)
//    }
//}
//
//extension AGHStack: Equatable {
//
//    public static func == (lhs: AGHStack, rhs: AGHStack) -> Bool {
//        guard lhs.graphs.count == rhs.graphs.count else { return false }
//        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
//            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
//        }
//        return true
//    }
//}
//
//extension AGHStack: Hashable {
//    
//    public func hash(into hasher: inout Hasher) {
//        for graph in graphs {
//            hasher.combine(graph)
//        }
//    }
//}
