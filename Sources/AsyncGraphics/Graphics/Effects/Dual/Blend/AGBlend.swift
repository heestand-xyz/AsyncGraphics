import CoreGraphics

public struct AGBlend: AGGraph {
    
    public let width: CGFloat? = nil
    public let height: CGFloat? = nil
    
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
    
    public func render(at resolution: CGSize) async throws -> Graphic {
        let leadingGraphic: Graphic = try await leadingGraph.render(at: resolution)
        let trailingGraphic: Graphic = try await trailingGraph.render(at: resolution)
        return try await leadingGraphic.blended(with: trailingGraphic, blendingMode: blendingMode)
    }
}

extension AGBlend: Equatable {

    public static func == (lhs: AGBlend, rhs: AGBlend) -> Bool {
        guard lhs.width == rhs.width else { return false }
        guard lhs.height == rhs.height else { return false }
        guard lhs.blendingMode == rhs.blendingMode else { return false }
        guard lhs.leadingGraph.isEqual(to: rhs.leadingGraph) else { return false }
        guard lhs.trailingGraph.isEqual(to: rhs.trailingGraph) else { return false }
        return true
    }
}

extension AGBlend: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(blendingMode)
        hasher.combine(leadingGraph)
        hasher.combine(trailingGraph)
    }
}
