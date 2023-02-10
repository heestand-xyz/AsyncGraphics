import CoreGraphics

public protocol AGGraph: Hashable {
    
    var resolution: AGResolution { get }
    
    func render(at resolution: CGSize) async throws -> Graphic
}

extension AGGraph {
    
    var width: CGFloat? {
        resolution.width
    }
    
    var height: CGFloat? {
        resolution.height
    }
}

extension AGGraph {
    
    public func isEqual(to graph: any AGGraph) -> Bool {
        guard let graph = graph as? Self else { return false }
        return self == graph
    }
}
