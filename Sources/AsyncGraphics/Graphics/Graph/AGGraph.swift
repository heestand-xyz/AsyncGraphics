import CoreGraphics

public protocol AGGraph: Hashable {
    
    var width: CGFloat? { get }
    var height: CGFloat? { get }
    
    func render(at resolution: CGSize) async throws -> Graphic
}

//extension AGGraph {
//    
//    public func dynamicRender(at resolution: CGSize) async throws -> Graphic {
//        let resolution = CGSize(width: width ?? resolution.width,
//                                height: height ?? resolution.height)
//        return try await render(at: resolution)
//    }
//}

extension AGGraph {
    
    public func isEqual(to graph: any AGGraph) -> Bool {
        guard let graph = graph as? Self else { return false }
        return self == graph
    }
}
