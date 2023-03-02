import CoreGraphics

public struct AGVStack: AGParentGraph {
    
    public var children: [any AGGraph] { graphs }
    
    let graphs: [any AGGraph]
    
    let alignment: Graphic.VStackAlignment
    let spacing: CGFloat
    
    public init(alignment: Graphic.VStackAlignment = .center,
                spacing: CGFloat = 8,
                @AGGraphBuilder with graphs: @escaping () -> [any AGGraph]) {
        self.alignment = alignment
        self.spacing = spacing * .pixelsPerPoint
        self.graphs = graphs()
    }
    
    private func maxWidth(for specification: AGSpecification) -> CGFloat {
        {
            var width: CGFloat = 0.0
            for childGraph in children.all {
                let dynamicResolution = childGraph.resolution(for: specification)
                if let fixedWidth: CGFloat = dynamicResolution.fixedWidth {
                    width = max(width, fixedWidth)
                } else if case .spacer = dynamicResolution {
                    continue
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
                                                         spacing: spacing,
                                                         with: childDynamicResolution)
        }
        return dynamicResolution
    }
    
//    private func autoHeight(_ childGraph: any AGGraph, at index: Int,
//                           maxWidth: CGFloat, isFixed: Bool,
//                           for specification: AGSpecification) -> CGFloat {
//
//        var height: CGFloat = specification.resolution.height
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
//                if let otherHeight = otherChildDynamicResolution.fixedHeight {
//                    list.append(.fixed(otherHeight))
//                    continue
//                }
//            } else {
//                if let otherHeight = otherChildDynamicResolution.height(forWidth: maxWidth) {
//                    list.append(.fixed(otherHeight))
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
//            height -= spacing
//        }
//
//        for item in list {
//            if case .fixed(let length) = item {
//                height -= length
//            }
//
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
//        height /= CGFloat(autoCount/* + (isAspectRatio ? 0 : spacerCount)*/ + spacerCount + 1)
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
//        height = max(height, minLengths)
//
//        return height
//    }
    
    func childResolution(_ childGraph: any AGGraph, at index: Int,
                         for specification: AGSpecification) -> CGSize {
        let maxWidth: CGFloat = maxWidth(for: specification)
        let childDynamicResolution: AGDynamicResolution = childGraph.resolution(for: specification)
        let width: CGFloat = childDynamicResolution.fixedWidth ?? maxWidth
//        let height: CGFloat = childDynamicResolution.fixedHeight ?? {
//            let heightA: CGFloat = autoHeight(childGraph, at: index, maxWidth: maxWidth, isFixed: true, for: specification)
//            let heightB: CGFloat = autoHeight(childGraph, at: index, maxWidth: maxWidth, isFixed: false, for: specification)
//            return max(heightA, heightB)
//        }()
        let height: CGFloat = childDynamicResolution.fixedHeight ?? {
            var otherChildren: [any AGGraph] = children.all
            otherChildren.remove(at: index)
            let otherChildDynamicResolutions: [AGDynamicResolution] = otherChildren.map { $0.resolution(for: specification) }
            return childDynamicResolution.vLength(totalHeight: specification.resolution.height, maxWidth: maxWidth, spacing: spacing, with: otherChildDynamicResolutions)
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
        return try await Graphic.vStacked(with: graphics, alignment: alignment, spacing: spacing)
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
