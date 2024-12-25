import CoreGraphics

extension AGGraph {
    
    public func mask(_ graph: () -> any AGGraph) -> any AGGraph {
        AGMask(child: self, modifierChild: graph())
    }
}

public struct AGMask: AGSingleModifierParentGraph {
    
    var child: any AGGraph
    var modifierChild: any AGGraph
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let leadingGraphic: Graphic = try await child.render(at: resolution, details: details)
        let trailingGraphic: Graphic = try await modifierChild.render(at: resolution, details: details)
            .alphaToLuminanceWithAlpha()
        return try await leadingGraphic.blended(with: trailingGraphic, blendingMode: .multiply)
    }
}

extension AGMask: Equatable {

    public static func == (lhs: AGMask, rhs: AGMask) -> Bool {
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.modifierChild.isEqual(to: rhs.modifierChild) else { return false }
        return true
    }
}

extension AGMask: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(child)
        hasher.combine(modifierChild)
    }
}
