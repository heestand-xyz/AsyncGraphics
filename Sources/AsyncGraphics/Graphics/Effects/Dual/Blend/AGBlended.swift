import CoreGraphics

extension AGGraph {
    
    public func blendMode(_ blendMode: AGBlendMode) -> any AGGraph {
        AGBlended(graph: self, blendMode: blendMode)
    }
}

public struct AGBlended: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let blendMode: AGBlendMode
    
    public var components: AGComponents {
        var components: AGComponents = graph.components
        if components.blendMode == nil {
            components.blendMode = blendMode
        }
        return components
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await graph.render(at: resolution, details: details)
    }
}

extension AGBlended: Equatable {

    public static func == (lhs: AGBlended, rhs: AGBlended) -> Bool {
        guard lhs.blendMode == rhs.blendMode else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGBlended: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(blendMode)
        hasher.combine(graph)
    }
}
