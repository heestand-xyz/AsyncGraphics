//
//  Created by Anton Heestand on 2023-02-06.
//

import SwiftUI
import CoreGraphicsExtensions

/// SwiftUI view for displaying a ``G``.
@available(iOS 15.0, tvOS 15.0, macOS 12.0, *)
public struct GView: View {
    
    private let g: () -> any G
    
    public init(g: @escaping () -> any G) {
        self.g = g
    }
    
    @State private var graphic: Graphic?
    
    @State private var resolution: CGSize = .zero
    
    @State private var renderTask: Task<Void, Never>?
    
    public var body: some View {
        ZStack {
            Color.clear
            if let graphic {
                GraphicView(graphic: graphic)
            }
        }
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
        .onChange(of: resolution) { resolution in
            print("--> resolution")
            render(at: resolution)
        }
        .onChange(of: g().hashValue) { _ in
            print("--> hash")
            render()
        }
    }
    
    private func render(at resolution: CGSize? = nil) {
        renderTask?.cancel()
        renderTask = Task {
            let resolution: CGSize = resolution ?? self.resolution
            do {
                graphic = try await g().render(at: resolution)
            } catch {
                print("Graphic failed to render:", error)
            }
        }
    }
}
