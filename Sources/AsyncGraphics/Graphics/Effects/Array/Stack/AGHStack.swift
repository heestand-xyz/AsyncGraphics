import CoreGraphics

public struct AGHStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.HStackAlignment
    let spacing: CGFloat
    
    public init(alignment: Graphic.HStackAlignment = .center,
                spacing: CGFloat = 8,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.spacing = spacing * .pixelsPerPoint
        self.graphs = graphs()
    }
    
//    private func maxHeight(for specification: AGSpecification) -> CGFloat {
//        {
//            var height: CGFloat = 0.0
//            for childGraph in children.all {
//                let dynamicResolution = childGraph.resolution(for: specification)
//                if let fixedHeight: CGFloat = dynamicResolution.fixedHeight {
//                    height = max(height, fixedHeight)
//                } else if case .spacer = dynamicResolution {
//                    continue
//                } else {
//                    return nil
//                }
//            }
//            return height
//        }() ?? specification.resolution.height
//    }
    
    private func stackItemResolution(at proposedResolution: CGSize) -> CGSize {
        CGSize(width: (proposedResolution.width - spacing * CGFloat(graphs.all.count - 1)) / CGFloat(graphs.all.count),
               height: proposedResolution.height)
    }
    
    private func leftoverResolution(graph: any AGGraph, index: Int,
                                    at proposedResolution: CGSize,
                                    for specification: AGSpecification) -> CGSize {
        let stackItemResolution: CGSize = stackItemResolution(at: proposedResolution)
        var width: CGFloat = proposedResolution.width - (spacing * CGFloat(graphs.all.count - 1))
        for (siblingIndex, siblingGraph) in graphs.all.enumerated() {
            if siblingIndex == index { continue }
//            if let spacer = siblingGraph as? AGSpacer {
//                width -= spacer.minLength
//                continue
//            }
            let siblingResolution: CGSize = siblingGraph.resolution(at: stackItemResolution, for: specification)
            width -= siblingResolution.width
        }
//        if let spacer = graph as? AGSpacer {
//            return CGSize(width: spacer.minLength, height: proposedResolution.height)
//        }
        return CGSize(width: width, height: proposedResolution.height)
    }
    
//    public func resolution(at proposedResolution: CGSize,
//                           for specification: AGSpecification) -> CGSize {
//        let stackItemResolution: CGSize = stackItemResolution(at: proposedResolution)
//        var width: CGFloat = spacing * CGFloat(graphs.all.count - 1)
//        var height: CGFloat = 0.0
//        for graph in graphs.all {
//            let graphResolution: CGSize = graph.resolution(at: stackItemResolution,
//                                                           for: specification)
//            width += graphResolution.width
//            height = max(height, graphResolution.height)
//        }
//        return CGSize(width: width, height: height)
//    }
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        var width: CGFloat = spacing * CGFloat(graphs.all.count - 1)
        var height: CGFloat = 0.0
        for (index, graph) in graphs.all.enumerated() {
            let leftoverResolution: CGSize = leftoverResolution(graph: graph, index: index, at: proposedResolution, for: specification)
            let graphResolution: CGSize = graph.resolution(at: leftoverResolution,
                                                           for: specification)
            width += graphResolution.width
            height = max(height, graphResolution.height)
        }
        return CGSize(width: width, height: height)
    }
    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        let maxHeight: CGFloat = maxHeight(for: specification)
//        var dynamicResolution: AGDynamicResolution = .zero
//        for child in children.all {
//            let childDynamicResolution = child.resolution(for: specification)
//            dynamicResolution = dynamicResolution.hMerge(maxHeight: maxHeight,
//                                                         spacing: spacing,
//                                                         with: childDynamicResolution)
//        }
//        return dynamicResolution
//    }
    
//    private func autoWidth(_ childGraph: any AGGraph, at index: Int,
//                           maxHeight: CGFloat, isFixed: Bool,
//                           for specification: AGSpecification) -> CGFloat {
//
//        var width: CGFloat = specification.resolution.width
//
//        enum Item {
//            case fixed(CGFloat)
//            case auto
//            case spacer(minLength: CGFloat)
//        }
//        var list: [Item] = []
//
//        for (otherIndex, otherGraph) in children.all.enumerated() {
//            guard otherIndex != index else { continue }
//            let otherChildDynamicResolution: AGDynamicResolution = otherGraph.resolution(for: specification)
//            if isFixed {
//                if let otherWidth = otherChildDynamicResolution.fixedWidth {
//                    list.append(.fixed(otherWidth))
//                    continue
//                }
//            } else {
//                if let otherWidth = otherChildDynamicResolution.width(forHeight: maxHeight) {
//                    list.append(.fixed(otherWidth))
//                    continue
//                }
//            }
//            if case .spacer(minLength: let minLength) = otherChildDynamicResolution {
//                list.append(.spacer(minLength: minLength))
//                continue
//            }
//            list.append(.auto)
//        }
//
//        for _ in 0..<list.count {
//            width -= spacing
//        }
//
//        for item in list {
//            if case .fixed(let length) = item {
//                width -= length
//            }
//        }
//
//        let autoCount: Int = list.filter({ item in
//            if case .auto = item {
//                return true
//            }
//            return false
//        }).count
//
//        let spacerCount: Int = list.filter({ item in
//            if case .spacer = item {
//                return true
//            }
//            return false
//        }).count
//
////        var isAspectRatio: Bool = false
////        if case .aspectRatio = childGraph.resolution(for: specification) {
////            isAspectRatio = true
////        }
//
//        width /= CGFloat(autoCount + spacerCount + 1)
//
//        let minLengths: CGFloat = list.compactMap({ item in
//            switch item {
//            case .spacer(let minLength):
//                return minLength
//            default:
//                return nil
//            }
//        }).reduce(0.0, +)
//
//        width = max(width, minLengths)
//
//        return width
//    }
    
//    func childResolution(_ childGraph: any AGGraph, at index: Int,
//                         for specification: AGSpecification) -> CGSize {
//        let maxHeight: CGFloat = maxHeight(for: specification)
//        let childDynamicResolution: AGDynamicResolution = childGraph.resolution(for: specification)
//        let height: CGFloat = childDynamicResolution.fixedHeight ?? maxHeight
////        let width: CGFloat = childDynamicResolution.fixedWidth ?? {
////            let flexWidth: CGFloat = autoWidth(childGraph, at: index, maxHeight: maxHeight, isFixed: false, for: specification)
////            let fixedWidth: CGFloat = autoWidth(childGraph, at: index, maxHeight: maxHeight, isFixed: true, for: specification)
////            return max(flexWidth, fixedWidth)
////        }()
//        let width: CGFloat = childDynamicResolution.fixedWidth ?? {
//            var otherChildren: [any AGGraph] = children.all
//            otherChildren.remove(at: index)
//            let otherChildDynamicResolutions: [AGDynamicResolution] = otherChildren.map { $0.resolution(for: specification) }
//            return childDynamicResolution.hLength(totalWidth: specification.resolution.width, maxHeight: maxHeight, spacing: spacing, with: otherChildDynamicResolutions)
//        }()
//        return CGSize(width: width, height: height)
//    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        guard !graphs.isEmpty else {
            return try await .color(.clear, resolution: proposedResolution)
        }
        var graphics: [Graphic] = []
        for (index, graph) in graphs.all.enumerated() {
            let leftoverResolution: CGSize = leftoverResolution(graph: graph, index: index, at: proposedResolution, for: details.specification)
            let graphic: Graphic = try await graph.render(at: leftoverResolution, details: details)
            graphics.append(graphic)
        }
        return try await Graphic.hStacked(with: graphics, alignment: alignment, spacing: spacing)
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
