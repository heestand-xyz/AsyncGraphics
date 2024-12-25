import CoreGraphics
import PixelColor
import SwiftUI

extension AGGraph {
    
    @available(iOS 14, macOS 11, *)
    public func foregroundColor(_ color: Color) -> AGForegroundColor {
        AGForegroundColor(graph: self, color: PixelColor(color))
    }
}

public struct AGForegroundColor: AGParentGraph {
   
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    let color: PixelColor
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        return try await graph.render(at: resolution, details: details.with(color: color))
    }
}

extension AGForegroundColor: Equatable {

    public static func == (lhs: AGForegroundColor, rhs: AGForegroundColor) -> Bool {
        guard lhs.color == rhs.color else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGForegroundColor: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(color)
        hasher.combine(graph)
    }
}
