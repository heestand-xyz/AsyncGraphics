import CoreGraphics

public protocol AGGraph: Hashable {
    
    func resolution(at proposedResolution: CGSize,
                    for specification: AGSpecification) -> CGSize
//    func resolution(for specification: AGSpecification) -> AGDynamicResolution
    
    func render(at proposedResolution: CGSize,
                details: AGDetails) async throws -> Graphic
}

extension AGGraph {
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        proposedResolution
    }
}

//extension AGGraph {
//
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        .auto
//    }
//
//    public func fallbackResolution(for specification: AGSpecification) -> CGSize {
//        resolution(from: specification.resolution, for: specification)
//    }
//}

extension AGGraph {
    
    public func isEqual(to graph: any AGGraph) -> Bool {
        guard let graph = graph as? Self else { return false }
        return self == graph
    }
}
