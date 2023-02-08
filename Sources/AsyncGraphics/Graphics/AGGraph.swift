import CoreGraphics

public protocol AGGraph: Hashable {
    
    var width: CGFloat? { get }
    var height: CGFloat? { get }
    
    func render(at resolution: CGSize) async throws -> Graphic
}

extension AGGraph {
    
    public func isEqual(to graph: any AGGraph) -> Bool {
        guard let graph = graph as? Self else { return false }
        return self == graph
    }
}
