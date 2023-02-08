import CoreGraphics

extension AGGraph {
    
    public func padding(on edgeInsets: Graphic.EdgeInsets = .all, _ length: CGFloat) -> any AGGraph {
        AGPadding(graph: self, edgeInsets: edgeInsets, padding: length)
    }
}

public struct AGPadding: AGGraphDirectEffect {
    
    let graph: any AGGraph
    
    public var width: CGFloat? {
        guard let width = graph.width
        else { return nil }
        return width + (edgeInsets.onLeading ? padding : 0) + (edgeInsets.onTrailing ? padding : 0)
    }
    public var height: CGFloat? {
        guard let height = graph.height
        else { return nil }
        return height + (edgeInsets.onTop ? padding : 0) + (edgeInsets.onBottom ? padding : 0)
    }
    
    let edgeInsets: Graphic.EdgeInsets
    let padding: CGFloat
    
    public func renderDirectEffect(at resolution: CGSize) async throws -> Graphic {
        var width: CGFloat = graph.width ?? resolution.width
        var height: CGFloat = graph.height ?? resolution.height
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
        let resolution = CGSize(width: width, height: height)
        let graphic: Graphic = try await graph.render(at: resolution)
        return try await graphic.padding(on: edgeInsets, padding)
    }
}

extension AGPadding: Equatable {

    public static func == (lhs: AGPadding, rhs: AGPadding) -> Bool {
        guard lhs.width == rhs.width else { return false }
        guard lhs.height == rhs.height else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGPadding: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(edgeInsets.rawValue)
        hasher.combine(padding)
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(graph)
    }
}
