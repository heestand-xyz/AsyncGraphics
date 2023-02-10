import CoreGraphics

extension AGGraph {
    
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> any AGGraph {
        AGFrame(graph: self, fixedWidth: width, fixedHeight: height)
    }
}

public struct AGFrame: AGGraph {
    
    public var resolution: AGResolution {
        AGResolution(width: fixedWidth ?? graph.width,
                     height: fixedHeight ?? graph.height)
    }
    
    let graph: any AGGraph
    
    let fixedWidth: CGFloat?
    let fixedHeight: CGFloat?
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        let resolution = CGSize(width: fixedWidth ?? resolution.width,
                                height: fixedHeight ?? resolution.height)
        return try await graph.render(at: resolution)
    }
}

extension AGFrame: Equatable {

    public static func == (lhs: AGFrame, rhs: AGFrame) -> Bool {
        guard lhs.resolution == rhs.resolution else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGFrame: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fixedWidth)
        hasher.combine(fixedHeight)
        hasher.combine(resolution)
        hasher.combine(graph)
    }
}
