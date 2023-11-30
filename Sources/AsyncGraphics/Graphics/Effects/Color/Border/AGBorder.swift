import CoreGraphics
import CoreGraphicsExtensions
import PixelColor

extension AGGraph {
    
    public func border(_ color: PixelColor) -> any AGGraph {
        AGBorder(child: self, color: color)
    }
}

public struct AGBorder: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let color: PixelColor
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let graphic: Graphic = try await child.render(at: resolution, details: details)
        let borderGraphic: Graphic = try await .strokedRectangle(
            size: resolution - .pixelsPerPoint,
            lineWidth: .pixelsPerPoint,
            color: color,
            backgroundColor: .clear,
            resolution: resolution)
        return try await borderGraphic.blended(with: graphic, blendingMode: .under, placement: .fixed)
    }
}

extension AGBorder: Equatable {

    public static func == (lhs: AGBorder, rhs: AGBorder) -> Bool {
        guard lhs.color == rhs.color else { return false }
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        return true
    }
}

extension AGBorder: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(color)
        hasher.combine(child)
    }
}
