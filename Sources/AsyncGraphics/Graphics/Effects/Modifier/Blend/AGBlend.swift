import CoreGraphics

extension AGGraph {
    
    public func overlay(content: @escaping () -> any AGGraph) -> any AGGraph {
        AGBlend(child: self, modifierChild: content(), blendMode: .over)
    }
}

public struct AGBlend: AGSingleModifierParentGraph {
    
    var child: any AGGraph
    let modifierChild: any AGGraph
    
    let blendMode: Graphic.BlendMode
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let leadingGraphic: Graphic = try await child.render(at: resolution, details: details)
        let trailingGraphic: Graphic = try await modifierChild.render(at: resolution, details: details)
        return try await leadingGraphic.blended(with: trailingGraphic, blendingMode: blendMode)
    }
}

extension AGBlend: Equatable {

    public static func == (lhs: AGBlend, rhs: AGBlend) -> Bool {
        guard lhs.blendMode == rhs.blendMode else { return false }
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.modifierChild.isEqual(to: rhs.modifierChild) else { return false }
        return true
    }
}

extension AGBlend: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(blendMode)
        hasher.combine(child)
        hasher.combine(modifierChild)
    }
}
