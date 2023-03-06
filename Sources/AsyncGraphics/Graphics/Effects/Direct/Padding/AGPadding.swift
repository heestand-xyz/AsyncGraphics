import CoreGraphics

extension AGGraph {
    
    public func padding(on edgeInsets: Graphic.EdgeInsets = .all, _ length: CGFloat) -> any AGGraph {
        AGPadding(graph: self, edgeInsets: edgeInsets, padding: length * .pixelsPerPoint)
    }
}

public struct AGPadding: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let edgeInsets: Graphic.EdgeInsets
    let padding: CGFloat
    
    var horizontalPadding: CGFloat {
        (edgeInsets.onLeading ? padding : 0) + (edgeInsets.onTrailing ? padding : 0)
    }
    
    var verticalPadding: CGFloat {
        (edgeInsets.onTop ? padding : 0) + (edgeInsets.onBottom ? padding : 0)
    }
    
    private func paddingResolution(at proposedResolution: CGSize) -> CGSize {
        CGSize(width: proposedResolution.width - horizontalPadding,
               height: proposedResolution.height - verticalPadding)
    }
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        let paddingResolution: CGSize = paddingResolution(at: proposedResolution)
        let graphResolution: CGSize = graph.resolution(at: paddingResolution, for: specification)
        return CGSize(width: graphResolution.width + horizontalPadding,
                      height: graphResolution.height + verticalPadding)
    }
    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        let outerResolution: CGSize = specification.resolution
//        let innerWidth: CGFloat = outerResolution.width - horizontalPadding
//        let innerHeight: CGFloat = outerResolution.height - verticalPadding
//        let innerResolution = CGSize(width: innerWidth, height: innerHeight)
//        let hPadding = (edgeInsets.onLeading ? padding : 0) + (edgeInsets.onTrailing ? padding : 0)
//        let vPadding = (edgeInsets.onTop ? padding : 0) + (edgeInsets.onBottom ? padding : 0)
//        let childDynamicResolution: AGDynamicResolution = graph.resolution(for: specification.with(resolution: innerResolution))
//        switch childDynamicResolution {
//        case .size(let size):
//            return .size(CGSize(width: size.width + hPadding,
//                                height: size.height + vPadding))
//        case .width(let width):
//            return .width(width + hPadding)
//        case .height(let height):
//            return .height(height + vPadding)
//        case .aspectRatio(let aspectRatio):
//            return .aspectRatio(aspectRatio)
//        case .auto, .spacer:
//            return .auto
//        }
//    }
    
//    func childResolution(_ childGraph: any AGGraph,
//                         at index: Int = 0,
//                         for specification: AGSpecification) -> CGSize {
//        let outerResolution: CGSize = fallbackResolution(for: specification)
//        let innerWidth: CGFloat = outerResolution.width - horizontalPadding
//        let innerHeight: CGFloat = outerResolution.height - verticalPadding
//        return CGSize(width: innerWidth, height: innerHeight)
//    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let paddingResolution: CGSize = paddingResolution(at: proposedResolution)
        guard paddingResolution.width > 0 && paddingResolution.height > 0 else {
            return try await .color(.clear, resolution: proposedResolution)
        }
        let graphic: Graphic = try await graph.render(at: paddingResolution, details: details)
        return try await graphic.padding(on: edgeInsets, padding)
    }
}

extension AGPadding: Equatable {

    public static func == (lhs: AGPadding, rhs: AGPadding) -> Bool {
        guard lhs.edgeInsets == rhs.edgeInsets else { return false }
        guard lhs.padding == rhs.padding else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGPadding: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(edgeInsets.rawValue)
        hasher.combine(padding)
        hasher.combine(graph)
    }
}
