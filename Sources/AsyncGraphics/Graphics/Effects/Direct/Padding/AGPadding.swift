import CoreGraphics

extension AGGraph {
    
    public func padding(on edgeInsets: Graphic.EdgeInsets = .all, _ length: CGFloat) -> any AGGraph {
        AGPadding(graph: self, edgeInsets: edgeInsets, padding: length)
    }
}

public struct AGPadding: AGGraph {
    
    let graph: any AGGraph
   
    public var resolution: AGResolution {
        AGResolution(
            width: {
                guard let width = graph.resolution.width else { return nil }
                return width + (edgeInsets.onLeading ? padding : 0) + (edgeInsets.onTrailing ? padding : 0)
            }(),
            height: {
                guard let height = graph.resolution.height else { return nil }
                return height + (edgeInsets.onTop ? padding : 0) + (edgeInsets.onBottom ? padding : 0)
            }()
        )
    }
    
    let edgeInsets: Graphic.EdgeInsets
    let padding: CGFloat
    
    public func render(at resolution: CGSize) async throws -> Graphic {
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
        let innerResolution = CGSize(width: width, height: height)
        guard innerResolution.width > 0 && innerResolution.height > 0 else {
            return try await .color(.clear, resolution: resolution)
        }
        let graphic: Graphic = try await graph.render(at: innerResolution)
        return try await graphic.padding(on: edgeInsets, padding)
    }
}

extension AGPadding: Equatable {

    public static func == (lhs: AGPadding, rhs: AGPadding) -> Bool {
        guard lhs.resolution == rhs.resolution else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGPadding: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(edgeInsets.rawValue)
        hasher.combine(padding)
        hasher.combine(resolution)
        hasher.combine(graph)
    }
}
