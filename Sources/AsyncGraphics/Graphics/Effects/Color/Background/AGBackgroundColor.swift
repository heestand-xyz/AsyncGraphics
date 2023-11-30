import CoreGraphics
import SwiftUI
import PixelColor

extension AGGraph {
    
    @available(iOS 14, macOS 11, *)
    public func background(_ color: Color) -> any AGGraph {
        AGBackgroundColor(child: self, backgroundColor: PixelColor(color))
    }
}

public struct AGBackgroundColor: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let backgroundColor: PixelColor
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let graphic: Graphic = try await child.render(at: resolution, details: details)
        let backgroundGraphic: Graphic = try await .color(backgroundColor, resolution: resolution)
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over)
    }
}

extension AGBackgroundColor: Equatable {

    public static func == (lhs: AGBackgroundColor, rhs: AGBackgroundColor) -> Bool {
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        guard lhs.backgroundColor == rhs.backgroundColor else { return false }
        return true
    }
}

extension AGBackgroundColor: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(child)
        hasher.combine(backgroundColor)
    }
}
