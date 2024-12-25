import CoreGraphics

extension AGGraph {
    
    @MainActor
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> any AGGraph {
        AGFrame(child: self,
                fixedWidth: width != nil ? width! * .pixelsPerPoint : nil,
                fixedHeight: height != nil ? height! * .pixelsPerPoint : nil)
    }
}

public struct AGFrame: AGSingleParentGraph {
    
    var child: any AGGraph
    
    let fixedWidth: CGFloat?
    let fixedHeight: CGFloat?
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        let proposedGraphResolution: CGSize = CGSize(width: fixedWidth ?? proposedResolution.width,
                                                     height: fixedHeight ?? proposedResolution.height)
        return child.resolution(at: proposedGraphResolution,
                                for: specification)
    }
    
    @MainActor
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let backgroundGraphic: Graphic = try await .color(.clear, resolution: resolution)
        let graphic: Graphic = try await child.render(at: resolution, details: details)
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over, placement: .fixed)
    }
}

extension AGFrame: Equatable {

    public static func == (lhs: AGFrame, rhs: AGFrame) -> Bool {
        guard lhs.fixedWidth == rhs.fixedWidth else { return false }
        guard lhs.fixedHeight == rhs.fixedHeight else { return false }
        guard lhs.child.isEqual(to: rhs.child) else { return false }
        return true
    }
}

extension AGFrame: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fixedWidth)
        hasher.combine(fixedHeight)
        hasher.combine(child)
    }
}
