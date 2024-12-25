import CoreGraphics

extension AGGraph {
    
    @MainActor
    public func blur(radius: CGFloat) -> any AGGraph {
        AGBlur(child: self, radius: radius * .pixelsPerPoint)
    }
}

public struct AGBlur: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let radius: CGFloat
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await child.render(at: resolution, details: details)
            .blurred(radius: radius)
    }
}

extension AGBlur: Equatable {

    public static func == (lhs: AGBlur, rhs: AGBlur) -> Bool {
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.radius == rhs.radius else { return false }
        return true
    }
}

extension AGBlur: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(child)
        hasher.combine(radius)
    }
}
