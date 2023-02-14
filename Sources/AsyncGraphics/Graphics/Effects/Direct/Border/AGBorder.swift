import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension AGGraph {
    
    public func border(_ color: PixelColor) -> any AGGraph {
        AGBorder(graph: self, color: color)
    }
}

public struct AGBorder: AGGraph {
    
    let graph: any AGGraph
    
    let color: PixelColor
    
    public func contentResolution(in containerResolution: CGSize) -> AGResolution {
        .auto
    }
    
    public func render(with details: AGRenderDetails) async throws -> Graphic {
        let graphic: Graphic = try await graph.render(with: details.with(resolution: details.resolution))
        let borderGraphic: Graphic = try await .strokedRectangle(size: details.resolution - .pixelsPerPoint, lineWidth: .pixelsPerPoint, color: color, backgroundColor: .clear, resolution: details.resolution)
        return try await graphic.blended(with: borderGraphic, blendingMode: .over)
    }
}

extension AGBorder: Equatable {

    public static func == (lhs: AGBorder, rhs: AGBorder) -> Bool {
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGBorder: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(graph)
    }
}
