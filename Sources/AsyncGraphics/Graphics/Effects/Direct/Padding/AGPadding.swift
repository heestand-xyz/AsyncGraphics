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
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        AGResolution(
            width: {
                guard let width = graph.contentResolution(with: specification).width else { return nil }
                return width + (edgeInsets.onLeading ? padding : 0) + (edgeInsets.onTrailing ? padding : 0)
            }(),
            height: {
                guard let height = graph.contentResolution(with: specification).height else { return nil }
                return height + (edgeInsets.onTop ? padding : 0) + (edgeInsets.onBottom ? padding : 0)
            }()
        )
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let outerResolution: CGSize = contentResolution(with: details.specification)
            .fallback(to: details.specification.resolution)
        var width: CGFloat = outerResolution.width
        var height: CGFloat = outerResolution.height
        if edgeInsets.onLeading {
            width -= padding
        }
        if edgeInsets.onTrailing {
            width -= padding
        }
        if edgeInsets.onTop {
            height -= padding
        }
        if edgeInsets.onBottom {
            height -= padding
        }
        let innerResolution = CGSize(width: width, height: height)
        guard innerResolution.width > 0 && innerResolution.height > 0 else {
            return try await .color(.clear, resolution: details.specification.resolution)
        }
        let graphic: Graphic = try await graph.render(with: details.with(resolution: innerResolution))
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
