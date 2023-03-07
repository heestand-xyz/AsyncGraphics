import CoreGraphics

extension AGGraph {
    
    public func overlay(content: @escaping () -> any AGGraph) -> any AGGraph {
        AGBlend(leadingGraph: self, trailingGraph: content(), blendMode: .over)
    }
}

public struct AGBlend: AGParentGraph {
    
    public var children: [any AGGraph] { [leadingGraph, trailingGraph] }
    
    let leadingGraph: any AGGraph
    let trailingGraph: any AGGraph
    
    let blendMode: AGBlendMode
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let leadingGraphic: Graphic = try await leadingGraph.render(at: resolution, details: details)
        let trailingGraphic: Graphic = try await trailingGraph.render(at: resolution, details: details)
        return try await leadingGraphic.blended(with: trailingGraphic, blendingMode: blendMode)
    }
}

extension AGBlend: Equatable {

    public static func == (lhs: AGBlend, rhs: AGBlend) -> Bool {
        guard lhs.blendMode == rhs.blendMode else { return false }
        guard lhs.leadingGraph.isEqual(to: rhs.leadingGraph) else { return false }
        guard lhs.trailingGraph.isEqual(to: rhs.trailingGraph) else { return false }
        return true
    }
}

extension AGBlend: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(blendMode)
        hasher.combine(leadingGraph)
        hasher.combine(trailingGraph)
    }
}
