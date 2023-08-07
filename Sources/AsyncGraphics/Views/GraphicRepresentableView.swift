//
//  Created by Anton Heestand on 2022-04-24.
//

#if !os(xrOS)

import SwiftUI

struct GraphicRepresentableView {
    
    private let graphic: Graphic
    private let viewResolution: CGSize
    private let interpolation: GraphicView.Interpolation
    private let extendedDynamicRange: Bool
    
    init(graphic: Graphic,
         viewResolution: CGSize,
         interpolation: GraphicView.Interpolation,
         extendedDynamicRange: Bool) {
        self.graphic = graphic
        self.viewResolution = viewResolution
        self.interpolation = interpolation
        self.extendedDynamicRange = extendedDynamicRange
    }
    
    private func render(in view: GraphicMetalView) {
        Task {
            var graphic: Graphic = graphic
            do {
                if graphic.colorSpace != .sRGB {
                    graphic = try await graphic
                        .applyColorSpace(.sRGB)
                }
                if [.nearestNeighbor, .linear].contains(interpolation) {
                    var options: Graphic.EffectOptions = []
                    if interpolation == .nearestNeighbor {
                        options.insert(.interpolateNearest)
                    }
                    graphic = try await graphic
                        .resized(to: viewResolution,
                                 placement: .stretch,
                                 options: options)
                }
                await view.render(graphic: graphic)
            } catch {
                print("AsyncGraphics - View Render Failed:", error)
            }
        }
    }
}
  
#if os(macOS)

extension GraphicRepresentableView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> GraphicMetalView {
        GraphicMetalView(interpolation: interpolation,
                         extendedDynamicRange: extendedDynamicRange)
    }
    
    func updateNSView(_ view: GraphicMetalView, context: Context) {
        if view.extendedDynamicRange != extendedDynamicRange {
            view.set(extendedDynamicRange: extendedDynamicRange)
        }
        render(in: view)
    }
}

#else

extension GraphicRepresentableView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GraphicMetalView {
        GraphicMetalView(interpolation: interpolation,
                         extendedDynamicRange: extendedDynamicRange)
    }
    
    func updateUIView(_ view: GraphicMetalView, context: Context) {
        if view.extendedDynamicRange != extendedDynamicRange {
            view.set(extendedDynamicRange: extendedDynamicRange)
        }
        render(in: view)
    }
}

#endif

#endif
