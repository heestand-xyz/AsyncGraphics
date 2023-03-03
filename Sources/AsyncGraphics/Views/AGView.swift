import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for displaying an ``AGGraph``.
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
    
    private var dynamicResolution: AGDynamicResolution? {
        guard let resolution else { return nil }
        let specification: AGSpecification = renderer.specification(for: graph(), at: resolution)
        return graph().resolution(for: specification)
    }
    
    @State private var renderTask: Task<Void, Never>?
    
    public var body: some View {
        ZStack {
            Color.clear
            if let graphic {
                if case .aspectRatio(let aspectRatio) = dynamicResolution {
                    GraphicView(graphic: graphic)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                } else {
                    GraphicView(graphic: graphic)
                        .frame(
                            width: {
                                guard let width: CGFloat = dynamicResolution?.fixedWidth
                                else { return nil }
                                return width / .pixelsPerPoint
                            }(),
                            height: {
                                guard let height: CGFloat = dynamicResolution?.fixedHeight
                                else { return nil }
                                return height / .pixelsPerPoint
                            }()
                        )
                }
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
                print("AsyncGraphics - AGView - Failed to render:", error)
            }
        }
    }
}
