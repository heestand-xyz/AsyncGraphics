import CoreGraphics

extension AGGraph {
    
    public func blendMode(_ blendMode: GraphicBlendMode) -> any AGGraph {
        AGBlended(child: self, blendMode: blendMode)
    }
}

public struct AGBlended: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let blendMode: GraphicBlendMode
    
    public var components: AGComponents {
        var components: AGComponents = child.components
        // TODO: Check if other stacks are needed
        if child is AGZStack || components.blendMode == nil {
            components.blendMode = blendMode
        }
        return components
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await child.render(at: resolution, details: details)
    }
}

extension AGBlended: Equatable {

    public static func == (lhs: AGBlended, rhs: AGBlended) -> Bool {
        guard lhs.blendMode == rhs.blendMode else { return false }
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        return true
    }
}

extension AGBlended: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(blendMode)
        hasher.combine(child)
    }
}
