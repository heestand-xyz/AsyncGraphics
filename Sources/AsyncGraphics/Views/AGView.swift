import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for displaying a ``AGGraphic``.
@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
public struct AGView: View {
   
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    private let graph: () -> any AGGraph
    
    public init(_ graph: @escaping () -> any AGGraph) {
        self.graph = graph
    }
    
    @State private var graphic: Graphic?
    
    @State private var resolution: CGSize = .zero
    
    @State private var renderTask: Task<Void, Never>?
    
    public var body: some View {
        ZStack {
            Color.clear
                .fixedSize(horizontal: false,
                           vertical: false)
            if let graphic {
                GraphicView(graphic: graphic)
            }
        }
        .frame(
            width: {
                guard let width: CGFloat = graph().contentResolution(in: resolution).width else { return nil }
                return width
            }(),
            height: {
                guard let height: CGFloat = graph().contentResolution(in: resolution).height else { return nil }
                return height
            }()
        )
        .background {
            GeometryReader { proxy in
                Color.clear
                    .task {
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
    }
    
    private func render(at resolution: CGSize? = nil) {
        renderTask?.cancel()
        renderTask = Task {
            let resolution: CGSize = resolution ?? self.resolution
            let details = AGRenderDetails(resolution: resolution, color: .primary)
            do {
                graphic = try await graph().render(with: details)
            } catch {
                if error is CancellationError { return }
                print("Async Graphics - AGView - Failed to render:", error)
            }
        }
    }
}
