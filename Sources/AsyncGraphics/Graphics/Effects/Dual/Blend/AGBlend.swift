import CoreGraphics

extension AGGraph {
    
    public func overlay(content: @escaping () -> any AGGraph) -> any AGGraph {
        AGBlend(mode: .over, { self }, with: content)
    }
}

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
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let leadingGraphic: Graphic = try await leadingGraph.render(at: resolution, details: details)
        let trailingGraphic: Graphic = try await trailingGraph.render(at: resolution, details: details)
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
