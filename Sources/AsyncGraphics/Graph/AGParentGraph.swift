import CoreGraphics

protocol AGParentGraph: AGGraph {
    
    var children: [any AGGraph] { get }
}

extension AGParentGraph {
    
    public var components: AGComponents {
        children.first?.components ?? .default
    }
}

extension AGParentGraph {
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        guard let child = children.first else { return proposedResolution }
        return child.resolution(at: proposedResolution, for: specification)
    }
}
