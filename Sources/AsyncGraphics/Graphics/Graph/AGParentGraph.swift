import CoreGraphics

protocol AGParentGraph: AGGraph {
    
    var children: [any AGGraph] { get }
    
//    func childResolution(_ childGraph: any AGGraph,
//                         at index: Int,
//                         for specification: AGSpecification) -> CGSize
}

extension AGParentGraph {
    
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        guard let child = children.first else { return proposedResolution }
        return child.resolution(at: proposedResolution, for: specification)
    }
    
//    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
//        guard let graph: any AGGraph = children.all.first else {
//            return .auto
//        }
//        return graph.resolution(for: specification)
//    }
    
//    func childResolution(_ childGraph: any AGGraph,
//                         at index: Int = 0,
//                         for specification: AGSpecification) -> CGSize {
//        childGraph.resolution(for: specification)
//            .fallback(to: specification.resolution)
//    }
}
