import CoreGraphics

extension AGGraph {
    
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> any AGGraph {
        AGFrame(graph: self,
                fixedWidth: width != nil ? width! * .pixelsPerPoint : nil,
                fixedHeight: height != nil ? height! * .pixelsPerPoint : nil)
    }
}

public struct AGFrame: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let fixedWidth: CGFloat?
    let fixedHeight: CGFloat?
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        AGResolution(width: fixedWidth ?? graph.contentResolution(with: specification).width,
                     height: fixedHeight ?? graph.contentResolution(with: specification).height)
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(with: details.specification)
            .fallback(to: details.specification.resolution)
        return try await graph.render(with: details.with(resolution: resolution))
    }
}

extension AGFrame: Equatable {

    public static func == (lhs: AGFrame, rhs: AGFrame) -> Bool {
        guard lhs.fixedWidth == rhs.fixedWidth else { return false }
        guard lhs.fixedHeight == rhs.fixedHeight else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGFrame: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fixedWidth)
        hasher.combine(fixedHeight)
        hasher.combine(graph)
    }
}
