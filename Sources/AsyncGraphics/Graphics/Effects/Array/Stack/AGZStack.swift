//import CoreGraphics
//
//public struct AGZStack: AGParentGraph {
//    
//    public var children: [any AGGraph] { graphs }
//    
//    let graphs: [any AGGraph]
//    
//    let alignment: Graphic.ZStackAlignment
//    
//    public init(alignment: Graphic.ZStackAlignment = .center,
//                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
//        self.alignment = alignment
//        self.graphs = graphs()
//    }
//    
//    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        if children.all.isEmpty {
//            return specification.resolution
//        }
//        var width: CGFloat = 0.0
//        var height: CGFloat = 0.0
//        for (index, child) in children.all.enumerated() {
//            let childResolution: CGSize = childResolution(for: child, at: index, for: specification)
//            width = max(width, childResolution.width)
//            height = max(height, childResolution.height)
//        }
//        return CGSize(width: width, height: height)
//    }
//    
//    public func render(with details: AGDetails) async throws -> Graphic {
//        guard !graphs.isEmpty else {
//            return try await .color(.clear, resolution: details.specification.resolution)
//        }
//        let resolution: CGSize = resolution(for: details.specification)
//        var graphics: [Graphic] = []
//        for graph in graphs.all {
//            let newDetails: AGDetails = details.with(resolution: resolution)
//            let graphic: Graphic = try await graph.render(with: newDetails)
//            graphics.append(graphic)
//        }
//        return try await Graphic.zStacked(with: graphics, alignment: alignment)
//    }
//}
//
//extension AGZStack: Equatable {
//
//    public static func == (lhs: AGZStack, rhs: AGZStack) -> Bool {
//        guard lhs.graphs.count == rhs.graphs.count else { return false }
//        for (lhsAGGraphic, rhsAGGraphic) in zip(lhs.graphs, rhs.graphs) {
//            guard lhsAGGraphic.isEqual(to: rhsAGGraphic) else { return false }
//        }
//        return true
//    }
//}
//
//extension AGZStack: Hashable {
//    
//    public func hash(into hasher: inout Hasher) {
//        for graph in graphs {
//            hasher.combine(graph)
//        }
//    }
//}
