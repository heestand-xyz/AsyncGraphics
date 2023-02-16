import CoreGraphics

public protocol AGGraph: Hashable {
    
    func contentResolution(with details: AGResolutionDetails) -> AGResolution
    
    func render(with details: AGRenderDetails) async throws -> Graphic
}

extension AGGraph {
    
    public func isEqual(to graph: any AGGraph) -> Bool {
        guard let graph = graph as? Self else { return false }
        return self == graph
    }
}
