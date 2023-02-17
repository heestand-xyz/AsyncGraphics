import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for displaying a ``AGGraphic``.
@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
public struct AGView: View {
   
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @StateObject private var renderer = AGGraphRenderer()
    
    private let graph: () -> any AGGraph
    
    public init(_ graph: @escaping () -> any AGGraph) {
        self.graph = graph
    }
    
    @State private var graphic: Graphic?
    
    @State private var resolution: CGSize?
    private var width: CGFloat? {
        guard let resolution else { return nil }
        let specification: AGSpecification = renderer.specification(for: graph(), at: resolution)
        return graph().contentResolution(with: specification).width
    }
    private var height: CGFloat? {
        guard let resolution else { return nil }
        let specification: AGSpecification = renderer.specification(for: graph(), at: resolution)
        return graph().contentResolution(with: specification).height
    }
    
    @State private var renderTask: Task<Void, Never>?
    
    public var body: some View {
        ZStack {
            Color.clear
            if let graphic {
                GraphicView(graphic: graphic)
                    .frame(
                        maxWidth: {
                            guard let width: CGFloat else { return nil }
                            return width / .pixelsPerPoint
                        }(),
                        maxHeight: {
                            guard let height: CGFloat else { return nil }
                            return height / .pixelsPerPoint
                        }()
                    )
            }
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        resolution = proxy.size * .pixelsPerPoint
                    }
                    .onChange(of: proxy.size) { newValue in
                        resolution = proxy.size * .pixelsPerPoint
                    }
            }
        }
        .onChange(of: colorScheme) { _ in
            render()
        }
        .onChange(of: resolution) { resolution in
            render(at: resolution)
        }
        .onChange(of: graph().hashValue) { _ in
            render()
        }
        .onChange(of: renderer.details(for: graph(), at: resolution ?? .one)) { details in
            render(details: details)
        }
    }
    
    private func render(at resolution: CGSize? = nil,
                        details: AGDetails? = nil) {
        guard let resolution: CGSize = resolution ?? self.resolution else { return }
        let graph: any AGGraph = graph()
        let details: AGDetails = details ?? renderer.details(for: graph, at: resolution)
        renderTask?.cancel()
        renderTask = Task {
            do {
                graphic = try await graph.render(with: details)
            } catch {
                if error is CancellationError { return }
                print("Async Graphics - AGView - Failed to render:", error)
            }
        }
    }
}
