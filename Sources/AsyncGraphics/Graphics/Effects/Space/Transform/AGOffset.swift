import CoreGraphics

extension AGGraph {
    
    public func offset(x: CGFloat = 0.0, y: CGFloat = 0.0) -> any AGGraph {
        AGOffset(child: self, offset: CGPoint(x: x * .pixelsPerPoint,
                                              y: y * .pixelsPerPoint))
    }
}

public struct AGOffset: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let offset: CGPoint
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await child.render(at: resolution, details: details)
            .offset(offset)
    }
}

extension AGOffset: Equatable {

    public static func == (lhs: AGOffset, rhs: AGOffset) -> Bool {
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.offset == rhs.offset else { return false }
        return true
    }
}

extension AGOffset: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(child)
        hasher.combine(offset)
    }
}
