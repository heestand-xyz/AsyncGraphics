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
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        let outerResolution: CGSize = specification.resolution
        let innerWidth: CGFloat = outerResolution.width - (edgeInsets.onLeading ? padding : 0) - (edgeInsets.onTrailing ? padding : 0)
        let innerHeight: CGFloat = outerResolution.height - (edgeInsets.onTop ? padding : 0) - (edgeInsets.onBottom ? padding : 0)
        let innerResolution = CGSize(width: innerWidth, height: innerHeight)
        let childDynamicResolution: AGDynamicResolution = graph.resolution(for: specification.with(resolution: innerResolution))
        return .semiAuto(
            fixedWidth: {
                guard let width: CGFloat = childDynamicResolution.width else { return nil }
                return width + (edgeInsets.onLeading ? padding : 0) + (edgeInsets.onTrailing ? padding : 0)
            }(),
            fixedHeight: {
                guard let height: CGFloat = childDynamicResolution.height else { return nil }
                return height + (edgeInsets.onTop ? padding : 0) + (edgeInsets.onBottom ? padding : 0)
            }()
        )
    }
    
    func childResolution(_ childGraph: any AGGraph,
                         at index: Int = 0,
                         for specification: AGSpecification) -> CGSize {
        let outerResolution: CGSize = fallbackResolution(for: specification)
        let innerWidth: CGFloat = outerResolution.width - (edgeInsets.onLeading ? padding : 0) - (edgeInsets.onTrailing ? padding : 0)
        let innerHeight: CGFloat = outerResolution.height - (edgeInsets.onTop ? padding : 0) - (edgeInsets.onBottom ? padding : 0)
        return CGSize(width: innerWidth, height: innerHeight)
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let childResolution: CGSize = childResolution(graph, for: details.specification)
        guard childResolution.width > 0 && childResolution.height > 0 else {
            return try await .color(.clear, resolution: details.specification.resolution)
        }
        let graphic: Graphic = try await graph.render(with: details.with(resolution: childResolution))
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
