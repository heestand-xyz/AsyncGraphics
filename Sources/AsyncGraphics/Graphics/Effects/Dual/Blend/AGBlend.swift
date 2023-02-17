import CoreGraphics

public struct AGBlend: AGParentGraph {
    
    public var children: [any AGGraph] { [leadingGraph, trailingGraph] }
    
    let leadingGraph: any AGGraph
    let trailingGraph: any AGGraph
    
    let blendingMode: BlendingMode
    
    public init(mode: BlendingMode,
                _ leadingGraph: @escaping () -> any AGGraph,
                with trailingGraph: @escaping () -> any AGGraph) {
        blendingMode = mode
        self.leadingGraph = leadingGraph()
        self.trailingGraph = trailingGraph()
    }
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        leadingGraph.contentResolution(with: specification)
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(with: details.specification)
            .fallback(to: details.specification.resolution)
        let leadingGraphic: Graphic = try await leadingGraph.render(with: details.with(resolution: resolution))
        let trailingGraphic: Graphic = try await trailingGraph.render(with: details.with(resolution: resolution))
        return try await leadingGraphic.blended(with: trailingGraphic, blendingMode: blendingMode)
    }
}

extension AGBlend: Equatable {

    public static func == (lhs: AGBlend, rhs: AGBlend) -> Bool {
        guard lhs.blendingMode == rhs.blendingMode else { return false }
        guard lhs.leadingGraph.isEqual(to: rhs.leadingGraph) else { return false }
        guard lhs.trailingGraph.isEqual(to: rhs.trailingGraph) else { return false }
        return true
    }
}

extension AGBlend: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(blendingMode)
        hasher.combine(leadingGraph)
        hasher.combine(trailingGraph)
    }
}
