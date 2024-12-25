import CoreGraphics

extension AGGraph {
    
    @MainActor
    public func padding(_ length: CGFloat) -> any AGGraph {
        padding(.all, length)
    }
    
    @MainActor
    public func padding(_ edgeInsets: Graphic.EdgeInsets, _ length: CGFloat = 16) -> any AGGraph {
        AGPadding(child: self, edgeInsets: edgeInsets, padding: length * .pixelsPerPoint)
    }
}

public struct AGPadding: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let edgeInsets: Graphic.EdgeInsets
    let padding: CGFloat
    
    var horizontalPadding: CGFloat {
        (edgeInsets.onLeading ? padding : 0) + (edgeInsets.onTrailing ? padding : 0)
    }
    
    var verticalPadding: CGFloat {
        (edgeInsets.onTop ? padding : 0) + (edgeInsets.onBottom ? padding : 0)
    }
    
    private func paddingResolution(at proposedResolution: CGSize) -> CGSize {
        CGSize(width: proposedResolution.width - horizontalPadding,
               height: proposedResolution.height - verticalPadding)
    }
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        let paddingResolution: CGSize = paddingResolution(at: proposedResolution)
        let graphResolution: CGSize = child.resolution(at: paddingResolution, for: specification)
        return CGSize(width: graphResolution.width + horizontalPadding,
                      height: graphResolution.height + verticalPadding)
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let paddingResolution: CGSize = paddingResolution(at: proposedResolution)
        guard paddingResolution.width > 0 && paddingResolution.height > 0 else {
            return try await .color(.clear, resolution: proposedResolution)
        }
        let graphic: Graphic = try await child.render(at: paddingResolution, details: details)
        return try await graphic.padding(on: edgeInsets, padding)
    }
}

extension AGPadding: Equatable {

    public static func == (lhs: AGPadding, rhs: AGPadding) -> Bool {
        guard lhs.edgeInsets == rhs.edgeInsets else { return false }
        guard lhs.padding == rhs.padding else { return false }
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        return true
    }
}

extension AGPadding: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(edgeInsets.rawValue)
        hasher.combine(padding)
        hasher.combine(child)
    }
}
