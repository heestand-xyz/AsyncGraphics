import CoreGraphics

protocol AGSingleModifierParentGraph: AGSingleParentGraph {
    
    var modifierChild: any AGGraph { get }
}

extension AGSingleModifierParentGraph {
    
    var children: [any AGGraph] {
        [child, modifierChild]
    }
}
