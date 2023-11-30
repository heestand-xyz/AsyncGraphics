import CoreGraphics

extension AGGraph {
    
    public func opacity(_ opacity: CGFloat) -> any AGGraph {
        AGOpacity(child: self, opacity: opacity)
    }
}

public struct AGOpacity: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let opacity: CGFloat
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await child.render(at: resolution, details: details)
            .opacity(opacity)
    }
}

extension AGOpacity: Equatable {

    public static func == (lhs: AGOpacity, rhs: AGOpacity) -> Bool {
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.opacity == rhs.opacity else { return false }
        return true
    }
}

extension AGOpacity: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(child)
        hasher.combine(opacity)
    }
}
