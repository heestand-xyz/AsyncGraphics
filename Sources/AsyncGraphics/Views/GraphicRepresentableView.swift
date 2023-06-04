//
//  Created by Anton Heestand on 2022-04-24.
//

import SwiftUI

#if os(macOS)

struct GraphicRepresentableView: NSViewRepresentable {
    
    private let graphic: Graphic
    private let viewResolution: CGSize
    private let interpolation: GraphicView.Interpolation
    
    init(graphic: Graphic,
         viewResolution: CGSize,
         interpolation: GraphicView.Interpolation) {
        self.graphic = graphic
        self.viewResolution = viewResolution
        self.interpolation = interpolation
    }
    
    func makeNSView(context: Context) -> GraphicMetalView {
        GraphicMetalView(interpolation: interpolation)
    }
    
    func updateNSView(_ view: GraphicMetalView, context: Context) {
        if [.nearestNeighbor, .linear].contains(interpolation) {
            Task {
                do {
                    var options: Graphic.EffectOptions = []
                    if interpolation == .nearestNeighbor {
                        options.insert(.interpolateNearest)
                    }
                    let graphic: Graphic = try await graphic
                        .resized(to: viewResolution,
                                 placement: .stretch,
                                 options: options)
                    view.render(graphic: graphic)
                } catch {
                    print("AsyncGraphics - View interpolation failed:", error)
                }
            }
        } else {
            view.render(graphic: graphic)
        }
    }
}

#else

struct GraphicRepresentableView: UIViewRepresentable {
    
    private let graphic: Graphic
    
    init(graphic: Graphic) {
        self.graphic = graphic
    }
    
    func makeUIView(context: Context) -> GraphicMetalView {
        GraphicMetalView()
    }
    
    func updateUIView(_ view: GraphicMetalView, context: Context) {
        view.render(graphic: graphic)
    }
}

#endif
