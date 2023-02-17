import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension AGGraph {
    
    public func border(_ color: PixelColor) -> any AGGraph {
        AGBorder(graph: self, color: color)
    }
}

public struct AGBorder: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let color: PixelColor
    
    public func contentResolution(with specification: AGSpecification) -> AGResolution {
        graph.contentResolution(with: specification)
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let resolution: CGSize = contentResolution(with: details.specification)
            .fallback(to: details.specification.resolution)
        let graphic: Graphic = try await graph.render(
            with: details.with(resolution: resolution))
        let borderGraphic: Graphic = try await .strokedRectangle(
            size: resolution - .pixelsPerPoint,
            lineWidth: .pixelsPerPoint,
            color: color,
            backgroundColor: .clear,
            resolution: resolution)
        return try await graphic.blended(with: borderGraphic, blendingMode: .over)
    }
}

extension AGBorder: Equatable {

    public static func == (lhs: AGBorder, rhs: AGBorder) -> Bool {
        guard lhs.color == rhs.color else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGBorder: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(color)
        hasher.combine(graph)
    }
}
