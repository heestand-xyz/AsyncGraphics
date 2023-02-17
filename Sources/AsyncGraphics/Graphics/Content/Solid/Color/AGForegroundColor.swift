import CoreGraphics
import PixelColor
import SwiftUI

extension AGGraph {
    
    public func foregroundColor(_ color: PixelColor) -> AGForegroundColor {
        AGForegroundColor(graph: self, color: color)
    }
}

public struct AGForegroundColor: AGGraph {
   
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    let color: PixelColor
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        graph.contentResolution(with: specification)
    }
    
    public func render(with details: AGDetails) async throws -> Graphic {
        try await graph.render(with: details.with(color: color))
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
