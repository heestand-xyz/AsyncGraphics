import CoreGraphics

extension AGGraph {
    
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> any AGGraph {
        AGFrame(graph: self,
                fixedWidth: width != nil ? width! * .pixelsPerPoint : nil,
                fixedHeight: height != nil ? height! * .pixelsPerPoint : nil)
    }
    
//    public func frame(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) -> any AGGraph {
//        // ...
//    }
}

public struct AGFrame: AGParentGraph {
    
    public var children: [any AGGraph] { [graph] }
    
    let graph: any AGGraph
    
    let fixedWidth: CGFloat?
    let fixedHeight: CGFloat?
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        let proposedGraphResolution: CGSize = CGSize(width: fixedWidth ?? proposedResolution.width,
                                                     height: fixedHeight ?? proposedResolution.height)
        return graph.resolution(at: proposedGraphResolution,
                                for: specification)
    }
    
    public func render(at proposedResolution: CGSize,
                       details: AGDetails) async throws -> Graphic {
        let resolution: CGSize = resolution(at: proposedResolution, for: details.specification)
        let backgroundGraphic: Graphic = try await .color(.clear, resolution: resolution)
        let graphic: Graphic = try await graph.render(at: resolution, details: details)
        return try await backgroundGraphic.blended(with: graphic, blendingMode: .over, placement: .center)
    }
}

extension AGFrame: Equatable {

    public static func == (lhs: AGFrame, rhs: AGFrame) -> Bool {
        guard lhs.fixedWidth == rhs.fixedWidth else { return false }
        guard lhs.fixedHeight == rhs.fixedHeight else { return false }
        guard lhs.graph.isEqual(to: rhs.graph) else { return false }
        return true
    }
}

extension AGFrame: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fixedWidth)
        hasher.combine(fixedHeight)
        hasher.combine(graph)
    }
}
