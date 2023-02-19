import CoreGraphics

public protocol AGGraph: Hashable {
    
    func resolution(for specification: AGSpecification) -> AGDynamicResolution
    
    func render(with details: AGDetails) async throws -> Graphic
}

extension AGGraph {
    
    public func resolution(for specification: AGSpecification) -> AGDynamicResolution {
        .auto
    }
    
    public func fallbackResolution(for specification: AGSpecification) -> CGSize {
        resolution(for: specification)
            .fallback(to: specification.resolution)
    }
}

extension AGGraph {
    
    public func isEqual(to graph: any AGGraph) -> Bool {
        guard let graph = graph as? Self else { return false }
        return self == graph
    }
}
