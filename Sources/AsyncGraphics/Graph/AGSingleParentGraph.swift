import CoreGraphics

protocol AGSingleParentGraph: AGParentGraph {
    
    var child: any AGGraph { get set }
}

extension AGSingleParentGraph {
    
    var children: [any AGGraph] {
        [child]
    }
}
