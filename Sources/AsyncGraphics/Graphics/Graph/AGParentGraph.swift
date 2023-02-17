import CoreGraphics

protocol AGParentGraph: AGGraph {
    
    var children: [any AGGraph] { get }
    
//    func childResolution(for childGraph: any AGGraph,
//                         at index: Int,
//                         with specification: AGSpecification) -> CGSize
}
