import CoreGraphics

extension AGGraph {
    
    public func mask(_ graph: () -> any AGGraph) -> any AGGraph {
        AGMask(leadingGraph: self, trailingGraph: graph())
    }
}

public struct AGMask: AGParentGraph {
    
    public var children: [any AGGraph] { [leadingGraph, trailingGraph] }
    
    let leadingGraph: any AGGraph
    let trailingGraph: any AGGraph
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let leadingGraphic: Graphic = try await leadingGraph.render(at: resolution, details: details)
        let trailingGraphic: Graphic = try await trailingGraph.render(at: resolution, details: details)
            .alphaToLuminanceWithAlpha()
        return try await leadingGraphic.blended(with: trailingGraphic, blendingMode: .multiply)
    }
}

extension AGMask: Equatable {

    public static func == (lhs: AGMask, rhs: AGMask) -> Bool {
        guard lhs.leadingGraph.isEqual(to: rhs.leadingGraph) else { return false }
        guard lhs.trailingGraph.isEqual(to: rhs.trailingGraph) else { return false }
        return true
    }
}

extension AGMask: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(leadingGraph)
        hasher.combine(trailingGraph)
    }
}
