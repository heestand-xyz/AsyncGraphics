import CoreGraphics
import SwiftUI
import PixelColor

extension AGGraph {
    
    public func background(_ graph: () -> (any AGGraph)) -> any AGGraph {
        AGBackground(child: self, modifierChild: graph())
    }
}

public struct AGBackground: AGSingleModifierParentGraph {
    
    var child: any AGGraph
    var modifierChild: any AGGraph
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let graphic: Graphic = try await child.render(at: resolution, details: details)
        let backgroundGraphic: Graphic = try await modifierChild.render(at: resolution, details: details)
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over)
    }
}

extension AGBackground: Equatable {

    public static func == (lhs: AGBackground, rhs: AGBackground) -> Bool {
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.modifierChild.isEqual(to: rhs.modifierChild) else { return false }
        return true
    }
}

extension AGBackground: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(child)
        hasher.combine(modifierChild)
    }
}
