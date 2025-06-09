import CoreGraphics

extension Graphic {
    
    /// Convert an ``AGGraph`` to a``Graphic``
    ///
    /// - Parameters:
    ///   - resolution: Size in pixels.
    ///   - renderer: An object that renders resources like image, video and camera.
    ///   Keep a strong reference to the graph renderer if you use resources in your graph hierarchy.
    ///   - graph: The root graph in the graph hierarchy.
    @MainActor
    public static func graph(resolution: CGSize, renderer: AGGraphRenderer = .init(), graph: @MainActor () -> any AGGraph) async throws -> Graphic {
        let graph: any AGGraph = graph()
        let details: AGDetails = renderer.details(for: graph, at: resolution)
        return try await graph.render(at: resolution, details: details)
    }
}
