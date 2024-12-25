import CoreGraphics

public protocol AGGraph: Hashable, Sendable {
    
    var components: AGComponents { get }
    
    @MainActor
    func resolution(at proposedResolution: CGSize,
                    for specification: AGSpecification) -> CGSize
    
    @MainActor
    func render(at proposedResolution: CGSize,
                details: AGDetails) async throws -> Graphic
}

extension AGGraph {
    
    public var components: AGComponents {
        .default
    }
}

extension AGGraph {
    
    @MainActor
    public func resolution(at proposedResolution: CGSize,
                           for specification: AGSpecification) -> CGSize {
        proposedResolution
    }
}

extension AGGraph {
    
    public func isEqual(to graph: any AGGraph) -> Bool {
        guard let graph = graph as? Self else { return false }
        return self == graph
    }
}
