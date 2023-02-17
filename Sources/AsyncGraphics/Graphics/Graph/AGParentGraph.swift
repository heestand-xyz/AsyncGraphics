import CoreGraphics

protocol AGParentGraph: AGGraph {
    
    var children: [any AGGraph] { get }
    
    func childResolution(for childGraph: any AGGraph,
                         at index: Int,
                         with specification: AGSpecification) -> CGSize
}

extension AGParentGraph {
    
    func childResolution(for childGraph: any AGGraph = AGSpacer(),
                         at index: Int = 0,
                         with specification: AGSpecification) -> CGSize {
        contentResolution(with: specification)
            .fallback(to: specification.resolution)
    }
}
